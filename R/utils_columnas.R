# =============================================================================
# utils_columnas.R  ·  Aplicar el crosswalk de COLUMNAS (Fase 2)
# -----------------------------------------------------------------------------
# Traduce las Col01..Col50 a agregados con sentido (65+, por sexo, marginales de
# equidad) usando crosswalk/crosswalk_demencia_columnas.csv. Lo sourcea el motor
# (04_engine.R) y 01_procesamiento.R. NO colapsa NA a 0 hasta el agregado final.
#
# Layout verificado (Fase 2) para los bloques con desagregacion etaria
# (P6 A.1/B.1, P3, A05): Col01-03 = TOTAL (ambos/H/M); Col04-37 = 17 bandas
# etarias x sexo; 65+ = Col30..Col37 (65-69,70-74,75-79,80+ x H/M).
# =============================================================================
source(here::here("R", "_setup.R"))

cargar_crosswalk_columnas <- function() {
  fread(file.path(PATHS$crosswalk, "crosswalk_demencia_columnas.csv"),
        encoding = "UTF-8")
}

# Suma un conjunto de columnas Col## de un data.table (NA -> 0 solo en la suma).
.suma_cols <- function(dt, cols) {
  cols <- intersect(cols, names(dt))
  if (!length(cols)) return(rep(NA_real_, nrow(dt)))
  m <- as.matrix(dt[, lapply(.SD, function(x) suppressWarnings(as.numeric(x))),
                    .SDcols = cols])
  rowSums(m, na.rm = TRUE)
}

# Para un codigo de prestacion con desagregacion etaria, devuelve el data.table
# de sus filas con columnas derivadas: total, h, m, n_65mas, pueblos_originarios,
# migrantes. 'seccion_anchor' selecciona el layout correcto del crosswalk
# (necesario porque P6 tiene A.1_APS y B.1_Especialidad con marginales iguales,
# pero P3/A05 difieren en la posicion de las marginales).
agregar_demencia_etario <- function(dt_codigo, cw_col, sec) {
  # IMPORTANTE: filtrar con un vector logico calculado FUERA del scope de
  # data.table. Si el argumento se llamara 'seccion' (igual que la columna),
  # data.table lo resolveria como la columna y el filtro no filtraria nada.
  keep <- cw_col$seccion == sec
  cc   <- cw_col[keep]
  col65   <- cc[es_65mas == "si", col]
  col_h   <- cc[sexo == "Hombres" & dimension == "edad_sexo", col]
  col_m   <- cc[sexo == "Mujeres" & dimension == "edad_sexo", col]
  col_po  <- cc[equidad == "pueblos_originarios", col]
  col_mig <- cc[equidad == "migrantes", col]
  out <- copy(dt_codigo)
  out[, total  := .suma_cols(out, "Col01")]
  out[, n_65mas := .suma_cols(out, col65)]
  out[, hombres := .suma_cols(out, col_h)]
  out[, mujeres := .suma_cols(out, col_m)]
  out[, pueblos_originarios := .suma_cols(out, col_po)]
  out[, migrantes := .suma_cols(out, col_mig)]
  out[]
}

# Validacion: total (Col01) ~ H+M ~ suma de bandas etarias. Devuelve un resumen.
validar_columnas <- function(dt_codigo, cw_col, sec, etiqueta = "") {
  keep <- cw_col$seccion == sec
  cc   <- cw_col[keep]
  edad_cols <- cc[dimension == "edad_sexo", col]
  tot   <- sum(.suma_cols(dt_codigo, "Col01"))
  hm    <- sum(.suma_cols(dt_codigo, c("Col02","Col03")))
  edad  <- sum(.suma_cols(dt_codigo, edad_cols))
  data.table(seccion = sec, etiqueta = etiqueta,
             total_col01 = tot, suma_h_m = hm, suma_bandas_edad = edad,
             ok_hm = isTRUE(all.equal(tot, hm)),
             dif_edad = tot - edad)
}
message("[utils_columnas.R] crosswalk de columnas listo.")
