# =============================================================================
# _paquetes.R  ·  Instala TODO lo necesario para el flujo (PC recien formateado)
# -----------------------------------------------------------------------------
# Correr UNA vez en la Consola de R:  source("R/_paquetes.R")
# Requisitos previos (fuera de R): tener instalado R (>= 4.2) y Quarto CLI
#   (https://quarto.org/docs/get-started/) para `quarto render`.
# En Windows, install.packages baja binarios: NO necesitas Rtools ni librerias
# de sistema para sf/spdep (vienen precompilados desde CRAN).
# =============================================================================

pkgs <- c(
  # --- núcleo de datos / utilidades ---
  "here",            # rutas relativas a la raíz del proyecto
  "data.table",      # lectura/manipulación de los CSV REM
  "stringr",         # texto
  "readxl",          # diccionarios .xlsm y proyecciones INE .xlsx
  # --- modelos ---
  "glmmTMB",         # multinivel logístico (09_sintesis.R, Q6)
  # --- espacial / mapas ---
  "sf",              # geometrías
  "spdep",           # Moran / LISA (06_analisis_deteccion.R)
  "leaflet",         # mapa interactivo (territorio.qmd)
  "leaflet.extras",  # capa de calor del mapa
  # --- dashboard / render ---
  "ggplot2",         # gráficos
  "scales",          # ejes en % y miles
  "DT",              # tablas interactivas
  "knitr",           # kable y motor de chunks
  "rmarkdown",       # render de .qmd con código R
  "quarto"           # interfaz R a Quarto (el CLI se instala aparte)
)

faltan <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(faltan)) {
  message("Instalando ", length(faltan), " paquetes: ", paste(faltan, collapse = ", "))
  install.packages(faltan, repos = "https://cloud.r-project.org")
} else {
  message("Todos los paquetes (binarios) ya están instalados.")
}

# --- chilemapas: caso especial -----------------------------------------------
# En R recientes (p. ej. 4.6.0) CRAN puede no tener binario aún. Es un paquete de
# solo datos/R (sin codigo compilado): se instala sin Rtools.
if (!requireNamespace("chilemapas", quietly = TRUE)) {
  hecho <- FALSE
  # Con renv activo, CRAN-source no resuelve; usar el remoto de GitHub via renv.
  if (requireNamespace("renv", quietly = TRUE)) {
    hecho <- tryCatch({ renv::install("pachadotdev/chilemapas"); TRUE },
                      error = function(e) FALSE)
  }
  if (!hecho && !requireNamespace("chilemapas", quietly = TRUE)) {
    hecho <- tryCatch({
      install.packages("chilemapas", type = "source",
                       repos = "https://cloud.r-project.org"); TRUE
    }, warning = function(w) FALSE, error = function(e) FALSE)
  }
  if (!requireNamespace("chilemapas", quietly = TRUE))
    message("chilemapas NO se instalo. Manual (con renv activo): ",
            'renv::install("pachadotdev/chilemapas")')
}

# Verificación final (incluye chilemapas)
todos <- c(pkgs, "chilemapas")
ok <- vapply(todos, requireNamespace, logical(1), quietly = TRUE)
if (all(ok)) message("OK: los ", length(todos), " paquetes del flujo están disponibles.") else
  warning("Faltan por instalar: ", paste(todos[!ok], collapse = ", "))
