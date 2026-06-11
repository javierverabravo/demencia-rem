# =============================================================================
# 06_analisis_deteccion.R  ·  Q1 RECTORA: Brecha de deteccion de demencia (Fase 5)
# -----------------------------------------------------------------------------
# Brecha = 1 - (bajo control SM por demencia 65+ / demencia esperada 65+), por
# comuna, con lente territorial (urbano/rural) y focos espaciales (Moran/LISA).
#
# Numerador (stock): P6222300 (APS) + P6223310 (Especialidad), 65+, CORTE UNICO
#   = diciembre (mes 12), para comparar contra una prevalencia que es stock
#   (no sumar jun+dic: duplicaria). Ver FASE_4 decisiones.
# Denominador: productos/denominadores.csv (INE 65+ x prevalencia 10/66,
#   ajustada urbano/rural si esta el archivo externo).
#
# Salidas: productos/brecha_comuna.csv  ·  productos/deteccion_resumen.csv
#          productos/modelo_estado.csv (estado del analisis espacial)
# =============================================================================
source(here::here("R", "_setup.R"))
source(here::here("R", "utils_columnas.R"))

cw_col <- cargar_crosswalk_columnas()
den <- fread(file.path(PATHS$productos, "denominadores.csv"),
             colClasses = list(character = "cod_comuna"))
den[, cod_comuna := sprintf("%05d", as.integer(cod_comuna))]

# --- 1. Numerador: bajo control 65+ por comuna (corte diciembre) --------------
P <- leer_serie_rem("P")
P[, cod_comuna := sprintf("%05d", as.integer(IdComuna))]
P[, mes_i := as.integer(Mes)]

num_por_comuna <- function(codigo, seccion) {
  sub <- P[CodigoPrestacion == codigo & mes_i == 12L]
  if (!nrow(sub)) return(data.table(cod_comuna = character(), n = numeric()))
  agg <- agregar_demencia_etario(sub, cw_col, seccion)
  agg[, .(n = sum(n_65mas, na.rm = TRUE)), by = cod_comuna]
}
n_aps <- num_por_comuna("P6222300", "A.1_APS")
n_esp <- num_por_comuna("P6223310", "B.1_Especialidad")
num <- merge(n_aps, n_esp, by = "cod_comuna", all = TRUE, suffixes = c("_aps", "_esp"))
num[is.na(n_aps), n_aps := 0]; num[is.na(n_esp), n_esp := 0]
num[, bajo_control_65 := n_aps + n_esp]

# --- 2. Brecha por comuna -----------------------------------------------------
ur_file <- file.path(PATHS$externos, "comunas_urbano_rural.csv")
ur <- if (file.exists(ur_file)) {
  x <- fread(ur_file, colClasses = list(character = "cod_comuna"))
  x[, cod_comuna := sprintf("%05d", as.integer(cod_comuna))]
  x[, .(cod_comuna, prop_rural)]
} else data.table(cod_comuna = character(), prop_rural = numeric())

# Trae esperados INE total y publico (FONASA) si existe; usa el publico como
# denominador primario (el REM solo mide la red publica).
cols_den <- intersect(c("cod_comuna","pob_65mas","demencia_esperada_65",
                        "demencia_esperada_65_pub","cobertura_publica","tramo_a_pct"),
                      names(den))
bre <- merge(den[, ..cols_den], num[, .(cod_comuna, bajo_control_65)],
             by = "cod_comuna", all.x = TRUE)
bre <- merge(bre, ur, by = "cod_comuna", all.x = TRUE)
bre[is.na(bajo_control_65), bajo_control_65 := 0]
setnames(bre, "demencia_esperada_65", "esperados_ine")
if (!"demencia_esperada_65_pub" %in% names(bre)) bre[, demencia_esperada_65_pub := NA_real_]
setnames(bre, "demencia_esperada_65_pub", "esperados_pub")
# denominador primario: publico si esta, si no el INE total
bre[, esperados := fifelse(!is.na(esperados_pub) & esperados_pub > 0,
                           esperados_pub, esperados_ine)]
bre[, denominador := fifelse(!is.na(esperados_pub) & esperados_pub > 0,
                             "FONASA_publico", "INE_total")]
bre <- bre[esperados > 0]
bre[, tasa_deteccion := bajo_control_65 / esperados]   # puede pasar de 1 en comunas chicas
bre[, brecha := pmax(0, 1 - tasa_deteccion)]
bre[, zona := fifelse(is.na(prop_rural), NA_character_,
                      fifelse(prop_rural >= 0.40, "rural",
                              fifelse(prop_rural <= 0.10, "urbano", "mixto")))]

# --- 3. Resumen nacional y por zona ------------------------------------------
resumen <- bre[, .(
  comunas = .N,
  bajo_control_65 = sum(bajo_control_65),
  esperados_65 = round(sum(esperados)),
  tasa_deteccion_pais = round(sum(bajo_control_65)/sum(esperados), 3),
  brecha_pais = round(1 - sum(bajo_control_65)/sum(esperados), 3)
)]
resumen_zona <- bre[!is.na(zona), .(
  comunas = .N,
  tasa_deteccion = round(sum(bajo_control_65)/sum(esperados), 3),
  brecha = round(1 - sum(bajo_control_65)/sum(esperados), 3)
), by = zona][order(zona)]
print(resumen); print(resumen_zona)
fwrite(rbind(resumen[, .(grupo = "PAIS", tasa_deteccion = tasa_deteccion_pais, brecha = brecha_pais)],
             resumen_zona[, .(grupo = zona, tasa_deteccion, brecha)]),
       file.path(PATHS$productos, "deteccion_resumen.csv"))

# --- 4. Focos espaciales: Moran global + LISA --------------------------------
# Analisis ecologico (caveat) + MAUP. zero.policy para comunas insulares.
estado_espacial <- "no_ejecutado"
moran_i <- NA_real_; moran_p <- NA_real_
ok_sp <- all(vapply(c("sf","spdep","chilemapas"), requireNamespace,
                    logical(1), quietly = TRUE))
if (ok_sp) {
  tryCatch({
    suppressPackageStartupMessages({library(sf); library(spdep); library(chilemapas)})
    mapa <- sf::st_as_sf(chilemapas::mapa_comunas)
    setDT(bre); m <- merge(mapa, bre, by.x = "codigo_comuna", by.y = "cod_comuna")
    m <- m[!is.na(m$tasa_deteccion), ]
    nb <- spdep::poly2nb(m, queen = TRUE)
    lw <- spdep::nb2listw(nb, style = "W", zero.policy = TRUE)
    mt <- spdep::moran.test(m$tasa_deteccion, lw, zero.policy = TRUE, na.action = na.omit)
    moran_i <- unname(mt$estimate[1]); moran_p <- mt$p.value
    lm <- as.data.table(spdep::localmoran(m$tasa_deteccion, lw, zero.policy = TRUE))
    x <- m$tasa_deteccion; xz <- x - mean(x, na.rm = TRUE)
    lagz <- spdep::lag.listw(lw, x, zero.policy = TRUE) - mean(x, na.rm = TRUE)
    p <- lm[[ncol(lm)]]
    cl <- fifelse(p >= 0.05, "ns",
           fifelse(xz > 0 & lagz > 0, "alto-alto",
            fifelse(xz < 0 & lagz < 0, "bajo-bajo",
             fifelse(xz > 0 & lagz < 0, "alto-bajo", "bajo-alto"))))
    res_sp <- data.table(cod_comuna = m$codigo_comuna, lisa_cluster = cl,
                         lisa_p = round(p, 4))
    bre <- merge(bre, res_sp, by = "cod_comuna", all.x = TRUE)
    estado_espacial <- "ok"
    message("Moran global I=", round(moran_i,3), " p=", signif(moran_p,3),
            " | focos bajo-bajo (brecha alta de deteccion): ",
            res_sp[lisa_cluster=="bajo-bajo", .N], " comunas")
  }, error = function(e) {
    estado_espacial <<- paste0("error: ", conditionMessage(e))
    message("[espacial] no se pudo completar: ", conditionMessage(e))
  })
} else {
  estado_espacial <- "faltan paquetes sf/spdep/chilemapas"
  message("[espacial] instala sf, spdep, chilemapas para Moran/LISA.")
}

# --- 5. Salidas ---------------------------------------------------------------
setorder(bre, brecha)
fwrite(bre, file.path(PATHS$productos, "brecha_comuna.csv"))
fwrite(data.table(analisis = "deteccion_espacial", estado = estado_espacial,
                  moran_i = moran_i, moran_p = moran_p),
       file.path(PATHS$productos, "modelo_estado.csv"))
message("\n[06] brecha por comuna escrita. CAVEATS: numerador = bajo control SM ",
        "(no es toda la demencia atendida); analisis ecologico + MAUP; el ",
        "subregistro rural (Fase 3) infla la brecha en comunas rurales.")
