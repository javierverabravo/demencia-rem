# =============================================================================
# 04_engine.R  ·  MOTOR analitico comun (parametrizado por bloque)  [Fase 5]
# -----------------------------------------------------------------------------
# Funciones que producen, para CUALQUIER bloque, los mismos productos:
# KPIs, cobertura, series, equidad marginal, modelos y tipologias. Los scripts
# por bloque (06-08) solo llaman estas funciones con parametros -> sin duplicar
# logica. La decision de modelos se toma con el diagnostico de Fase 1/3
# (exceso de ceros + cola -> hurdle/binomial negativa; ver rem-estadistica).
# =============================================================================
source(here::here("R", "_setup.R"))
source(here::here("R", "utils_columnas.R"))   # crosswalk de columnas (65+, equidad)

# --- KPIs y cobertura de un bloque -------------------------------------------
engine_kpis <- function(panel, bloque) {
  # TODO: nro de personas/atenciones, cobertura (% estab. activos),
  #       intensidad (volumen medio por estab. activo), serie temporal.
  stop("engine_kpis: pendiente Fase 5")
}

# --- Modelo de conteo / tasa con verificacion de convergencia -----------------
engine_modelo <- function(panel, tipo = c("hurdle","nbinom","poisson_offset")) {
  # TODO: ajustar segun estructura observada; registrar convergencia en
  #       productos/modelo_estado.csv (se muestra en el dashboard).
  stop("engine_modelo: pendiente Fase 5")
}

# --- Equidad marginal (PO / migrantes) por seccion ---------------------------
engine_equidad <- function(panel, denominador) {
  # TODO: % marginal de pueblos originarios / migrantes por seccion y etapa,
  #       contra peso poblacional comunal (Censo 2024). SIN cruces entre marginales.
  stop("engine_equidad: pendiente Fase 5")
}

# --- Multinivel (establecimiento ⊂ comuna ⊂ region): ICC + MOR ----------------
engine_multinivel <- function(panel) {
  # TODO: glmmTMB con efectos anidados; ICC, MOR, PCV. Servicio de Salud alterno.
  stop("engine_multinivel: pendiente Fase 5")
}
message("[04] motor cargado (stubs Fase 5).")
