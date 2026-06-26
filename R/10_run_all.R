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
  "00_descarga.R",            # insumos crudos (ZIP REM + maestro)          [ACTIVO]
  "01_procesamiento.R",       # crosswalk, filtro demencia, diagnostico celdas [ACTIVO]
  "01b_panel.R",              # panel + cobertura/subregistro (Fase 3)      [ACTIVO]
  "03_denominadores.R",       # INE 65+ + demencia esperada (Fase 4)        [ACTIVO]
  "06_analisis_deteccion.R",  # Q1 brecha + LISA (Fase 5)                   [ACTIVO]
  "06b_centros_geo.R",        # capa de centros para mapa de calor          [ACTIVO]
  "11_sensibilidad_prevalencia.R", # triangulacion del denominador (A1)     [ACTIVO]
  "07_analisis_cascada.R",    # Q2 cascada                                  [ACTIVO]
  "08_analisis_equidad.R",    # Q5 equidad                                  [ACTIVO]
  "09_sintesis.R"             # Q6 multinivel (barrera registro)            [ACTIVO]
)
# Nota: 02_datos_comunales.R, 04_engine.R y 05_indicadores.R eran stubs sin salida
# usada (el motor comun no se implemento; la logica vive en 06-09; urbano/rural y
# pobreza se leen directo de datos/externos) -> retirados del pipeline.
# Ver plan_mejora.md (A5).

# Falla ruidosamente: acumula los errores y, si hubo alguno, termina con error.
# Asi una corrida con un script roto NO se reporta como "completado".
fallas <- character(0)
for (s in scripts) {
  message("\n==== ", s, " ====")
  tryCatch(source(here::here("R", s)),
           error = function(e) {
             msg <- paste0(s, ": ", conditionMessage(e))
             fallas <<- c(fallas, msg)
             message("   [ERROR en ", s, "] ", conditionMessage(e))
           })
}
if (length(fallas)) {
  message("\n[run_all] TERMINADO CON ERRORES (", length(fallas), "):")
  for (f in fallas) message("  - ", f)
  stop("run_all: ", length(fallas), " script(s) fallaron; revisar arriba.")
}
message("\n[run_all] completado sin errores. Render del sitio:  quarto render")
