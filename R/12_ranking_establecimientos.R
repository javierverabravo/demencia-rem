# =============================================================================
# 12_ranking_establecimientos.R  ·  Insumo de la app de priorizacion (Fase 6)
# -----------------------------------------------------------------------------
# Construye productos/ranking_establecimientos.csv: por cada APS activo, su
# puntaje de prioridad de intervencion, combinando
#   (1) DEFICIT de registro ajustado por contexto = -efecto aleatorio del centro
#       (BLUP del intercepto del multinivel, productos/ranef_establecimiento.csv);
#   (2) VOLUMEN de poblacion expuesta = inscritos FONASA 60+ (centros_geo.csv);
#   (3) PONDERADOR de equidad territorial (realce rural, opcional).
# La app SOLO consume este archivo; el computo pesado vive aqui (rem-pipeline).
#
# Parametros (Sys.setenv antes de correr):
#   REM_W_RURAL  realce de centros rurales en el puntaje (default 1.3)
# Salida: productos/ranking_establecimientos.csv
# Correr DESPUES de 06b_centros_geo.R y 09_sintesis.R.
# =============================================================================
source(here::here("R", "_setup.R"))

W_RURAL <- as.numeric(Sys.getenv("REM_W_RURAL", "1.3"))

ref_file <- file.path(PATHS$productos, "ranef_establecimiento.csv")
geo_file <- file.path(PATHS$productos, "centros_geo.csv")
if (!file.exists(ref_file))
  stop("Falta productos/ranef_establecimiento.csv (corre 09_sintesis.R).")
if (!file.exists(geo_file))
  stop("Falta productos/centros_geo.csv (corre 06b_centros_geo.R).")

ref <- fread(ref_file, colClasses = list(character = "cod_estab"))
geo <- fread(geo_file, colClasses = list(character = c("cod_estab","cod_comuna")))

# contexto del maestro: Servicio de Salud y region (no estan en centros_geo)
maestro <- as.data.table(readRDS(file.path(PATHS$datos, "establecimientos.rds")))
mcols <- intersect(c("cod_estab","servicio_salud","cod_servicio_salud",
                     "region","cod_region"), names(maestro))
maestro <- unique(maestro[, ..mcols], by = "cod_estab")
maestro[, cod_estab := as.character(cod_estab)]

# zona urbano/rural por comuna
ur_file <- file.path(PATHS$externos, "comunas_urbano_rural.csv")
ur <- if (file.exists(ur_file)) {
  x <- fread(ur_file, colClasses = list(character = "cod_comuna"))
  x[, .(cod_comuna = sprintf("%05d", as.integer(cod_comuna)),
        zona = fifelse(prop_rural >= 0.40, "rural",
                fifelse(prop_rural <= 0.10, "urbano", "mixto")))]
} else data.table(cod_comuna = character(), zona = character())

# --- Ensamblar ---------------------------------------------------------------
r <- merge(ref, geo, by = "cod_estab", all.x = TRUE)   # ranef = universo APS activo
r <- merge(r, maestro, by = "cod_estab", all.x = TRUE)
r <- merge(r, ur, by = "cod_comuna", all.x = TRUE)

# --- Componentes del puntaje -------------------------------------------------
# Deficit: solo cuenta el registro POR DEBAJO de lo esperado (ef negativo).
r[, deficit := pmax(0, -ef_registro)]
# Volumen: log de inscritos 60+ (centros sin dato -> 0, baja prioridad).
r[, insc := fifelse(is.na(inscritos_60), 0, as.numeric(inscritos_60))]
r[, vol := log1p(insc)]
# Normalizacion 0..1 y realce rural.
nrm <- function(x) { rng <- range(x, na.rm = TRUE)
  if (diff(rng) == 0) return(rep(0, length(x))); (x - rng[1]) / diff(rng) }
r[, w := fifelse(!is.na(zona) & zona == "rural", W_RURAL, 1)]
r[, score := round(100 * nrm(deficit) * nrm(vol) * w, 1)]

# --- Prioridad por terciles del puntaje (entre los que tienen deficit) -------
pos <- r[deficit > 0 & score > 0, score]
if (length(pos) >= 3) {
  cortes <- quantile(pos, c(1/3, 2/3), na.rm = TRUE)
  r[, prioridad := fcase(
    deficit <= 0 | score <= 0, "Baja",
    score >= cortes[2], "Alta",
    score >= cortes[1], "Media",
    default = "Baja")]
} else r[, prioridad := fifelse(score > 0, "Alta", "Baja")]

# --- Resguardo de celdas pequenas (A2): tasa de deteccion enmascarada --------
r[, deteccion_pub := fifelse(!is.na(deteccion) & bajo_control_65 >= 5, deteccion, NA_real_)]

# --- Salida ------------------------------------------------------------------
out <- r[, .(cod_estab, nombre, tipo, comuna, cod_comuna,
             region, servicio_salud, zona,
             inscritos_60 = insc, bajo_control_65,
             deteccion = deteccion_pub, ef_registro = round(ef_registro, 3),
             deficit = round(deficit, 3), score, prioridad, lat, lon)]
setorder(out, -score)
fwrite(out, file.path(PATHS$productos, "ranking_establecimientos.csv"))

message("\n[12] ranking escrito: ", nrow(out), " establecimientos | ",
        out[prioridad == "Alta", .N], " prioridad Alta, ",
        out[prioridad == "Media", .N], " Media. W_RURAL=", W_RURAL,
        ". CAVEAT: el deficit mide registro administrativo, no calidad clinica.")
