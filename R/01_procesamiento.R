# =============================================================================
# 01_procesamiento.R  ·  Lectura, crosswalk, filtro del universo demencia
#                        y DIAGNOSTICO DE CELDAS (entregable Fase 1)
# -----------------------------------------------------------------------------
# Reproduce FASE_1_DATOS.md:
#   - mezcla de celdas global por serie (% NA / % ceros / % positivos)
#   - mezcla de celdas por bloque del universo demencia + distribucion
# Y deja amarrado el filtro del universo (crosswalk de prestaciones).
# El panel completo establecimiento x mes/semestre se construye en Fase 3.
#
# Modos (variables de entorno, set antes del source):
#   REM_DIAG_FULL = "1"  -> escanea TODAS las series completas (lento en Serie A)
#                   "0"  -> omite el global de Serie A (default en verificacion)
# Salidas: productos/diagnostico_celdas_global.csv
#          productos/diagnostico_celdas_bloque.csv
# =============================================================================
source(here::here("R", "_setup.R"))

FULL <- Sys.getenv("REM_DIAG_FULL", "1") == "1"
cw   <- cargar_crosswalk()

# --- Helper: mezcla de celdas (NA / cero / positivo) sobre Col01..Col50 -------
# Vectorizado por columna (50 iteraciones), sin melt: apto para Serie A (7M filas).
mezcla_celdas <- function(dt) {
  na <- zero <- pos <- 0
  for (cc in COLS_VALOR) {
    v  <- dt[[cc]]
    es_na <- is.na(v) | v == ""
    num   <- suppressWarnings(as.numeric(v))
    na   <- na   + sum(es_na)
    zero <- zero + sum(!es_na & !is.na(num) & num == 0)
    pos  <- pos  + sum(!es_na & (is.na(num) | num != 0))  # texto no-numerico -> pos
  }
  tot <- na + zero + pos
  data.table(filas = nrow(dt),
             pct_na = 100*na/tot, pct_cero = 100*zero/tot, pct_pos = 100*pos/tot)
}

# --- 1. Diagnostico GLOBAL por serie -----------------------------------------
series_todas <- c("A", "BS", "BM", "P", "D")
glob <- rbindlist(lapply(series_todas, function(s) {
  if (s == "A" && !FULL) {
    message("[diag] Serie A global OMITIDA (REM_DIAG_FULL=0)"); return(NULL)
  }
  message("[diag] global Serie ", s, " ...")
  dt <- leer_serie_rem(s)
  cbind(serie = s, mezcla_celdas(dt))
}), fill = TRUE)
fwrite(glob, file.path(PATHS$productos, "diagnostico_celdas_global.csv"))
print(glob)

# --- 2. Filtro del universo demencia + diagnostico POR BLOQUE -----------------
# Solo series con codigos de demencia (A, BS, P). Filtra por CodigoPrestacion.
diag_bloque <- function(s) {
  codigos <- cw[serie == s, codigo_prestacion]
  if (!length(codigos)) return(NULL)
  dt <- leer_serie_rem(s)
  sub <- dt[CodigoPrestacion %in% codigos]
  if (!nrow(sub)) return(NULL)
  # Matriz numerica de las 50 Col (siempre matriz, aun con 1 fila); NA preservado.
  M <- as.matrix(sub[, lapply(.SD, function(x) suppressWarnings(as.numeric(x))),
                     .SDcols = COLS_VALOR])
  sub[, row_sum := rowSums(M, na.rm = TRUE)]
  sub[, mes_i  := as.integer(Mes)]
  # Mezcla de celdas y distribucion por codigo de prestacion
  out <- sub[, {
    blk   <- M[.I, , drop = FALSE]          # .I = posiciones en 'sub' del grupo
    es_na <- is.na(blk)
    na <- sum(es_na); zero <- sum(!es_na & blk == 0); pos <- sum(!es_na & blk != 0)
    tot <- na + zero + pos
    .(serie = s,
      bloque = cw[codigo_prestacion == .BY$CodigoPrestacion, bloque][1],
      descripcion = cw[codigo_prestacion == .BY$CodigoPrestacion, descripcion][1],
      filas = .N,
      establecimientos = uniqueN(IdEstablecimiento),
      meses = paste(sort(unique(mes_i)), collapse = "|"),
      pct_na = 100*na/tot, pct_cero = 100*zero/tot, pct_pos = 100*pos/tot,
      volumen = sum(row_sum),
      mediana_fila = as.numeric(median(row_sum)),
      max_fila = max(row_sum))
  }, by = CodigoPrestacion]
  out[]
}
bloque <- rbindlist(lapply(c("A", "BS", "P"), diag_bloque), fill = TRUE)
setorder(bloque, serie, bloque, CodigoPrestacion)
fwrite(bloque, file.path(PATHS$productos, "diagnostico_celdas_bloque.csv"))
print(bloque)

# --- 3. Panel completo (PENDIENTE Fase 3) ------------------------------------
# TODO: cruzar el universo filtrado contra la base maestra de establecimientos
#   (00_descarga.R) para reconstruir establecimiento x mes (A/BS) y x semestre (P),
#   y calcular cobertura / subregistro / intensidad por tipo y nivel.
message("[01] diagnostico de celdas escrito en productos/. Panel completo -> Fase 3.")
