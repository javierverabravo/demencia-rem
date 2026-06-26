# =============================================================================
# global.R  ·  Carga comun de la app de priorizacion de establecimientos
# -----------------------------------------------------------------------------
# La app SOLO consume productos/ (no recalcula el analisis). Si falta el ranking,
# degrada con elegancia y muestra como generarlo.
# Correr:  shiny::runApp("app")   (desde la raiz del proyecto)
# =============================================================================
suppressPackageStartupMessages({
  library(shiny); library(bslib); library(data.table); library(DT)
})
HAS_LEAFLET <- requireNamespace("leaflet", quietly = TRUE)
if (HAS_LEAFLET) suppressPackageStartupMessages(library(leaflet))

PROD <- here::here("productos")
rd <- function(f) { p <- file.path(PROD, f); if (file.exists(p)) fread(p) else NULL }

RANK    <- rd("ranking_establecimientos.csv")
RESUMEN <- rd("deteccion_resumen.csv")
SENS    <- rd("sensibilidad_prevalencia.csv")

# Parametros de presentacion
PREV60 <- 0.07   # prevalencia 60+ (10/66) para tasa indicativa a nivel de centro
COL_PRIO <- c(Alta = "#A32D2D", Media = "#854F0B", Baja = "#3B6D11")

# Helpers de formato
pct <- function(x, d = 1) ifelse(is.na(x), "s/i", paste0(formatC(100*x, format="f", digits=d), "%"))
mil <- function(x) ifelse(is.na(x), "s/i", formatC(round(x), format="d", big.mark="."))

# Choices del filtro global (Servicio de Salud)
SS_CHOICES <- if (!is.null(RANK) && "servicio_salud" %in% names(RANK))
  c("Todos", sort(unique(na.omit(RANK$servicio_salud)))) else "Todos"

# Brecha pais + intervalo (de la triangulacion)
brecha_pais <- if (!is.null(RESUMEN)) RESUMEN[grupo == "PAIS", brecha][1] else NA_real_
ic_pais <- if (!is.null(SENS) && "brecha_lo95" %in% names(SENS))
  SENS[fuente == "10_66_raw", c(brecha_lo95, brecha_hi95)] else c(NA, NA)

# Carga explicita de los modulos (ademas de la autocarga de Shiny), por robustez.
for (f in list.files("R", pattern = "[.]R$", full.names = TRUE)) source(f, local = FALSE)
