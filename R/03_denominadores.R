# =============================================================================
# 03_denominadores.R  ·  Denominadores y demencia esperada por comuna (Fase 4)
# -----------------------------------------------------------------------------
# - Proyecciones INE base 2017 (comuna x sexo x edad x ano) -> poblacion 65+/60+
#   comunal para el ano del REM.
# - Prevalencia de demencia por banda etaria (estudio 10/66 Chile; FASE_0 3.1),
#   ajuste urbano/rural -> DEMENCIA ESPERADA por comuna (denominador de Q1).
# - Verifica el cruce comunal contra el REM/maestro. Degrada con elegancia si
#   falta el archivo urbano/rural (usa prevalencia total).
# Salida: productos/denominadores.csv
# =============================================================================
source(here::here("R", "_setup.R"))
if (!requireNamespace("readxl", quietly = TRUE))
  install.packages("readxl", repos = "https://cloud.r-project.org")

# --- 1. Descarga proyecciones INE comunales ----------------------------------
url_ine <- paste0("https://www.ine.gob.cl/docs/default-source/proyecciones-de-poblacion/",
                  "cuadros-estadisticos/base-2017/estimaciones-y-proyecciones-2002-2035-comunas.xlsx")
ine_xlsx <- file.path(PATHS$externos, "ine_proyecciones_comunas.xlsx")
if (!file.exists(ine_xlsx)) {
  message("Descargando proyecciones INE comunales (base 2017)...")
  options(timeout = 900); download.file(url_ine, ine_xlsx, mode = "wb")
}
# Deteccion robusta de la fila de encabezado (los xlsx del INE a veces traen
# filas de titulo antes de la tabla): buscar la fila que contiene "Edad".
crudo <- as.data.table(readxl::read_excel(ine_xlsx, col_names = FALSE, n_max = 15))
fila_hdr <- which(apply(crudo, 1, function(r)
  any(grepl("^edad$", trimws(as.character(r)), ignore.case = TRUE)))) [1]
skip_n <- if (is.na(fila_hdr)) 0L else fila_hdr - 1L
ine <- as.data.table(readxl::read_excel(ine_xlsx, skip = skip_n))
setnames(ine, names(ine), trimws(names(ine)))
message("Fila de encabezado detectada: ", skip_n + 1, ". Columnas:")
print(names(ine))

# --- 2. Deteccion robusta de columnas clave ----------------------------------
pick <- function(patron) {
  hit <- grep(patron, names(ine), ignore.case = TRUE, value = TRUE)
  if (!length(hit)) stop("No encuentro columna que matchee: ", patron)
  hit[1]
}
col_comuna <- pick("^comuna$|c[oó]digo.*comuna|^comuna.?cod")     # codigo comunal
col_nombre <- pick("nombre.*comuna|^comuna$")                       # glosa (puede coincidir)
col_sexo   <- pick("sexo")
col_edad   <- pick("edad")
col_anio   <- grep(paste0("(^|[^0-9])", PARAMS$anio, "([^0-9]|$)"), names(ine), value = TRUE)[1]
if (is.na(col_anio)) stop("No encuentro la columna del ano ", PARAMS$anio,
                          " en el archivo INE. Revisa names(ine) impreso arriba.")
message("Usando: comuna=", col_comuna, " | sexo=", col_sexo, " | edad=", col_edad,
        " | ano=", col_anio)

d <- ine[, .(cod_comuna = as.character(get(col_comuna)),
             edad = suppressWarnings(as.integer(get(col_edad))),
             pob  = suppressWarnings(as.numeric(get(col_anio))))]
d <- d[!is.na(edad) & !is.na(pob)]
# normaliza codigo comunal a 5 digitos (con cero a la izquierda) para cruzar con REM
d[, cod_comuna := sprintf("%05d", as.integer(cod_comuna))]

# --- 3. Bandas etarias y prevalencia (10/66 Chile) ---------------------------
banda_de <- function(e) fcase(
  e %in% 60:64, "60-64", e %in% 65:69, "65-69", e %in% 70:74, "70-74",
  e %in% 75:79, "75-79", e %in% 80:84, "80-84", e >= 85, "85+", default = NA_character_)
d[, banda := banda_de(edad)]

prev <- data.table(
  banda       = c("60-64","65-69","70-74","75-79","80-84","85+"),
  prev_total  = c(0.012, 0.041, 0.037, 0.088, 0.194, 0.326),
  prev_urbano = c(0.0094,0.039, 0.030, 0.084, 0.172, 0.290),
  prev_rural  = c(0.026, 0.051, 0.069, 0.106, 0.297, 0.504))

# poblacion por comuna x banda (solo 60+)
pob_cb <- d[!is.na(banda), .(pob = sum(pob)), by = .(cod_comuna, banda)]

# --- 4. Ajuste urbano/rural (degrada a prevalencia total si falta el archivo) -
# Archivo manual opcional: datos/externos/comunas_urbano_rural.csv
#   columnas: cod_comuna, prop_rural  (0..1, proporcion de poblacion rural; Censo 2024)
ur_file <- file.path(PATHS$externos, "comunas_urbano_rural.csv")
if (file.exists(ur_file)) {
  ur <- fread(ur_file, colClasses = list(character = "cod_comuna"))
  ur[, cod_comuna := sprintf("%05d", as.integer(cod_comuna))]
  message("Ajuste urbano/rural ACTIVO (", ur_file, ")")
} else {
  ur <- unique(pob_cb[, .(cod_comuna)]); ur[, prop_rural := NA_real_]
  message("[degradacion elegante] sin archivo urbano/rural -> uso prevalencia TOTAL. ",
          "Para activar el ajuste, deja datos/externos/comunas_urbano_rural.csv ",
          "(cod_comuna, prop_rural).")
}

pob_cb <- merge(pob_cb, prev,  by = "banda", all.x = TRUE)
pob_cb <- merge(pob_cb, ur,    by = "cod_comuna", all.x = TRUE)
# prevalencia efectiva por banda: si hay prop_rural, mezcla urbano/rural; si no, total
pob_cb[, prev_efectiva := fifelse(
  is.na(prop_rural), prev_total,
  (1 - prop_rural) * prev_urbano + prop_rural * prev_rural)]
pob_cb[, esperados := pob * prev_efectiva]

# --- 5. Denominadores por comuna ---------------------------------------------
den <- pob_cb[, .(
  pob_60mas = sum(pob),
  pob_65mas = sum(pob[banda != "60-64"]),
  demencia_esperada_60 = round(sum(esperados)),
  demencia_esperada_65 = round(sum(esperados[banda != "60-64"]))
), by = cod_comuna]

# --- 5b. Denominador del SUBSISTEMA PUBLICO: FONASA inscritos APS -------------
# El REM solo mide la red publica; el denominador correcto es la poblacion
# inscrita en FONASA (no toda la poblacion, que incluye isapres). Se escala el
# esperado 65+ por la cobertura publica del 60+ (banda comun limpia con FONASA).
# Tambien deja % tramo A (indigencia) como proxy de pobreza comunal.
# Autodetectado; degrada con elegancia si falta el archivo o el maestro.
fonasa_path <- c(here::here("Fonasa Inscritos APS 2025 12.csv"),
                 file.path(PATHS$externos, "fonasa_inscritos_aps.csv"))
fonasa_path <- fonasa_path[file.exists(fonasa_path)][1]
maestro_rds <- file.path(PATHS$datos, "establecimientos.rds")
den[, c("fonasa_60mas","cobertura_publica","demencia_esperada_65_pub","tramo_a_pct") :=
      .(NA_real_, NA_real_, NA_real_, NA_real_)]
if (!is.na(fonasa_path) && file.exists(maestro_rds)) {
  fon <- fread(fonasa_path, encoding = "UTF-8")
  setnames(fon, names(fon), trimws(names(fon)))
  mst <- as.data.table(readRDS(maestro_rds))[, .(cod_estab = as.character(cod_estab),
                                                  cod_comuna_m = cod_comuna)]
  fon[, COD_CENTRO := as.character(COD_CENTRO)]
  fon <- merge(fon, mst, by.x = "COD_CENTRO", by.y = "cod_estab", all.x = TRUE)
  fon[, cod_comuna := sprintf("%05d", as.integer(cod_comuna_m))]
  fon[, ins := suppressWarnings(as.numeric(TOTAL_INSCRITOS))]
  es60 <- grepl("60 a 69|70 a 79|80 a m", fon$EDAD_TRAMO)
  f60 <- fon[es60, .(fonasa_60mas = sum(ins, na.rm = TRUE)), by = cod_comuna]
  ftot <- fon[, .(tot = sum(ins, na.rm = TRUE),
                  insA = sum(ins[TRAMO_FONASA == "A"], na.rm = TRUE)), by = cod_comuna]
  ftot[, tramo_a_pct := round(100 * insA / tot, 1)]
  den[, c("fonasa_60mas","cobertura_publica","demencia_esperada_65_pub","tramo_a_pct") := NULL]
  den <- merge(den, f60, by = "cod_comuna", all.x = TRUE)
  den <- merge(den, ftot[, .(cod_comuna, tramo_a_pct)], by = "cod_comuna", all.x = TRUE)
  den[, cobertura_publica := pmin(1, fonasa_60mas / pob_60mas)]
  den[, demencia_esperada_65_pub := round(demencia_esperada_65 * cobertura_publica)]
  cob_pais <- den[, sum(fonasa_60mas, na.rm=TRUE)/sum(pob_60mas)]
  message("FONASA APS ACTIVO (", basename(fonasa_path),
          "): cobertura publica 60+ pais = ", round(100*cob_pais,1), "%")
} else {
  message("[degradacion elegante] sin FONASA -> denominador = poblacion INE total. ",
          "Para activarlo deja el CSV de inscritos APS en la raiz o datos/externos/.")
}

fwrite(den, file.path(PATHS$productos, "denominadores.csv"))
message("\nComunas con denominador: ", nrow(den),
        " | demencia esperada 65+ INE total (pais): ", den[, sum(demencia_esperada_65)],
        if (!all(is.na(den$demencia_esperada_65_pub)))
          paste0(" | publica FONASA (pais): ", den[, sum(demencia_esperada_65_pub, na.rm=TRUE)]) else "")

# --- 6. Verificacion del cruce comunal contra el REM -------------------------
rem_comunas <- unique(leer_serie_rem("P")[, sprintf("%05d", as.integer(IdComuna))])
m <- mean(rem_comunas %in% den$cod_comuna)
message("Cruce comunal REM <-> INE: ", round(100*m, 1), "% de comunas del REM con denominador")
faltan <- setdiff(rem_comunas, den$cod_comuna)
if (length(faltan)) message("  comunas REM sin match (revisar comunas nuevas/codigos): ",
                            paste(head(faltan, 10), collapse = ", "))

message("\n[03] denominadores escritos. Brecha = bajo_control(P6) / demencia_esperada -> Fase 5.")
