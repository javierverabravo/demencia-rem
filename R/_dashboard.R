# Helpers comunes del dashboard. Lo sourcean los .qmd en su chunk de setup.
# REGLA DE ORO: solo se leen tablas de productos/. Nada de datos crudos aquí.
suppressPackageStartupMessages({
  library(data.table); library(ggplot2); library(here)
})
PROD <- here::here("productos")
leer_prod <- function(f, ...) {
  ruta <- file.path(PROD, f)
  if (!file.exists(ruta)) { warning("Falta ", ruta, " (corre R/10_run_all.R)"); return(NULL) }
  fread(ruta, ...)
}
pct <- function(x, d = 1) paste0(formatC(100 * x, format = "f", digits = d), " %")
mil <- function(x) formatC(x, format = "d", big.mark = ".")

theme_rem <- function() {
  theme_minimal(base_size = 13) +
    theme(panel.grid.minor = element_blank(),
          plot.title = element_text(face = "bold"),
          axis.title = element_text(color = "#52616b"))
}
COL_PRIMARY <- "#2C5F7C"; COL_ALERT <- "#b3431f"
