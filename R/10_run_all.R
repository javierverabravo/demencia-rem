# =============================================================================
# 10_run_all.R  ·  Orquesta TODO el pipeline en orden
# -----------------------------------------------------------------------------
# Reproduccion completa:  source("R/10_run_all.R")  + luego  quarto render
# Las flechas solo avanzan hacia productos/: el dashboard/informe leen de ahi.
#
# Modos (set antes del source):
#   REM_DIAG_FULL=1  diagnostico de celdas sobre todas las series (Serie A lenta)
#   (futuros: *_PAR paralelo, *_FAST nAGQ, *_SENS sensibilidad — ver rem-pipeline)
# =============================================================================
suppressMessages(source(here::here("R", "_setup.R")))

scripts <- c(
  "00_descarga.R",        # insumos crudos (ZIP REM + maestro establecimientos) [ACTIVO]
  "01_procesamiento.R",   # crosswalk, filtro demencia, DIAGNOSTICO CELDAS (Fase 1) [ACTIVO]
  "01b_panel.R",          # panel + cobertura/subregistro (Fase 3)            [ACTIVO]
  "02_datos_comunales.R", # covariables comunales            [Fase 4 - pendiente]
  "03_denominadores.R",   # INE 65+ + demencia esperada       [Fase 4 - ACTIVO]
  "05_indicadores.R",     # tasas con denominador             [Fase 5 - pendiente]
  "06_analisis_deteccion.R", # Q1 brecha + LISA               [Fase 5 - ACTIVO]
  "07_analisis_cascada.R",   # Q2 cascada                     [Fase 5 - ACTIVO]
  "08_analisis_equidad.R",   # Q5 equidad                     [Fase 5 - ACTIVO]
  "09_sintesis.R"            # Q6 multinivel (barrera registro) [Fase 5 - ACTIVO]
)
# 04_engine.R no se corre solo (lo sourcean 06-09).

for (s in scripts) {
  message("\n==== ", s, " ====")
  tryCatch(source(here::here("R", s)),
           error = function(e) message("   [salta ", s, "] ", conditionMessage(e)))
}
message("\n[run_all] completado. Render del sitio:  quarto render")
