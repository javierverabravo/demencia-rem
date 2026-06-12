# =============================================================================
# 06b_centros_geo.R  ·  Capa geográfica de centros para el mapa de calor (Fase 6)
# -----------------------------------------------------------------------------
# Arma productos/centros_geo.csv: un punto por establecimiento, con su
# lat/long (DEIS), su VOLUMEN de demencia 65+ bajo control y su TASA DE DETECCIÓN
# (bajo control / esperados, donde esperados = inscritos FONASA 60+ del centro ×
# prevalencia). Alimenta el mapa de calor de focos de la página Territorio.
#
# Caveat (declarado en el dashboard): la tasa por centro es un PROXY. Es limpia
# para APS (cada persona se inscribe a un centro); para hospitales el universo
# inscrito no aplica igual -> se marca y la detección queda NA (se muestran por
# volumen). Numerador 65+ vs inscritos 60+: aproximación aceptable para focos.
# Salida: productos/centros_geo.csv
# =============================================================================
source(here::here("R", "_setup.R"))
num <- function(x) suppressWarnings(as.numeric(gsub(",", ".", as.character(x))))
pick <- function(dt, cands) { hit <- intersect(cands, names(dt)); if (length(hit)) hit[1] else NA }

# --- 1. Maestro con coordenadas (lee el CSV crudo cacheado) ------------------
estab_csv <- file.path(PATHS$datos, "establecimientos.csv")
if (!file.exists(estab_csv)) stop("Falta datos/establecimientos.csv (corre 00_descarga.R).")
est <- fread(estab_csv, encoding = "UTF-8")
setnames(est, names(est), trimws(names(est)))
c_cod <- pick(est, c("EstablecimientoCodigo")); c_lat <- pick(est, c("Latitud"))
c_lon <- pick(est, c("Longitud")); c_tipo <- pick(est, c("TipoEstablecimientoGlosa"))
c_nom <- pick(est, c("EstablecimientoGlosa")); c_com <- pick(est, c("ComunaCodigo"))
c_comg <- pick(est, c("ComunaGlosa")); c_niv <- pick(est, c("NivelAtencionEstabglosa"))
geo <- data.table(
  cod_estab = as.character(est[[c_cod]]),
  nombre = if (!is.na(c_nom)) as.character(est[[c_nom]]) else NA_character_,
  tipo   = if (!is.na(c_tipo)) as.character(est[[c_tipo]]) else NA_character_,
  comuna = if (!is.na(c_comg)) as.character(est[[c_comg]]) else NA_character_,
  cod_comuna = if (!is.na(c_com)) sprintf("%05d", as.integer(est[[c_com]])) else NA_character_,
  nivel  = if (!is.na(c_niv)) as.character(est[[c_niv]]) else NA_character_,
  lat = num(est[[c_lat]]), lon = num(est[[c_lon]]))
geo <- geo[!is.na(lat) & !is.na(lon) & lat < -17 & lat > -56 & lon < -65 & lon > -110]
geo <- unique(geo, by = "cod_estab")

# --- 2. Bajo control 65+ por establecimiento (P6, corte diciembre) -----------
col65 <- sprintf("Col%02d", 30:37)   # 65-69..80+ x sexo (verificado Fase 2)
P <- leer_serie_rem("P")
p6 <- P[as.integer(Mes) == 12L & CodigoPrestacion %in% c("P6222300","P6223310")]
M <- as.matrix(p6[, lapply(.SD, num), .SDcols = col65])
p6[, bc65 := rowSums(M, na.rm = TRUE)]
bc <- p6[, .(bajo_control_65 = sum(bc65, na.rm = TRUE)),
         by = .(cod_estab = as.character(IdEstablecimiento))]

# --- 3. Inscritos FONASA 60+ por centro (denominador) ------------------------
fon_path <- c(here::here("Fonasa Inscritos APS 2025 12.csv"),
              file.path(PATHS$externos, "fonasa_inscritos_aps.csv"))
fon_path <- fon_path[file.exists(fon_path)][1]
ins <- NULL
if (!is.na(fon_path)) {
  fon <- fread(fon_path, encoding = "UTF-8"); setnames(fon, names(fon), trimws(names(fon)))
  fon[, ins := num(TOTAL_INSCRITOS)]
  es60 <- grepl("60 a 69|70 a 79|80 a m", fon$EDAD_TRAMO)
  ins <- fon[es60, .(inscritos_60 = sum(ins, na.rm = TRUE)),
             by = .(cod_estab = as.character(COD_CENTRO))]
}

# --- 4. Ensamblar y calcular detección ---------------------------------------
geo <- merge(geo, bc, by = "cod_estab", all.x = TRUE)
geo[is.na(bajo_control_65), bajo_control_65 := 0]
if (!is.null(ins)) geo <- merge(geo, ins, by = "cod_estab", all.x = TRUE)
if (!"inscritos_60" %in% names(geo)) geo[, inscritos_60 := NA_real_]

PREV60 <- PARAMS$prevalencia_60mas    # 0.07 (10/66, global 60+)
es_aps <- grepl("CESFAM|Posta|CECOSF|Consultorio|Centro de Salud(?!.*Mental)", geo$tipo, perl = TRUE)
geo[, esperados := fifelse(!is.na(inscritos_60) & inscritos_60 > 0, inscritos_60 * PREV60, NA_real_)]
geo[, deteccion := fifelse(es_aps & !is.na(esperados) & esperados >= 3,
                           pmin(bajo_control_65 / esperados, 1.2), NA_real_)]
# Mantener solo centros con alguna señal (registran demencia o tienen inscritos)
geo <- geo[bajo_control_65 > 0 | (!is.na(inscritos_60) & inscritos_60 > 0)]

setcolorder(geo, c("cod_estab","nombre","tipo","comuna","cod_comuna","nivel","lat","lon",
                   "inscritos_60","esperados","bajo_control_65","deteccion"))
fwrite(geo, file.path(PATHS$productos, "centros_geo.csv"))
message("[06b] centros_geo.csv: ", nrow(geo), " centros georreferenciados | ",
        "con detección (APS): ", geo[!is.na(deteccion), .N],
        " | con bajo control >0: ", geo[bajo_control_65 > 0, .N])
