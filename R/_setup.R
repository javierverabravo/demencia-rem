# =============================================================================
# _setup.R  ·  Configuracion comun del pipeline (paquetes, rutas, parametros)
# -----------------------------------------------------------------------------
# Se sourcea al inicio de CADA script numerado. No produce salidas: solo deja
# en el entorno las rutas (here), los paquetes y los parametros del proyecto.
# Reglas: here::here() para todo; nada de rutas absolutas; NA != 0.
# =============================================================================

# --- Paquetes -----------------------------------------------------------------
# Instalacion bajo demanda (idempotente). En Positron usa tu libreria local.
.pkgs <- c(
  "here",        # rutas relativas a la raiz del proyecto
  "data.table",  # lectura/manipulacion rapida de los CSV grandes
  "readxl",      # diccionarios .xlsm
  "stringr"
  # Fases posteriores (descomentar cuando se usen):
  # "glmmTMB", "MASS",      # modelos hurdle / binomial negativa / multinivel
  # "sf", "chilemapas",     # geometrias comunales, Moran/LISA
  # "spdep",                # autocorrelacion espacial
  # "quarto"                # render del dashboard/informe
)
.faltan <- .pkgs[!vapply(.pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(.faltan)) {
  message("Instalando paquetes faltantes: ", paste(.faltan, collapse = ", "))
  install.packages(.faltan, repos = "https://cloud.r-project.org")
}
suppressPackageStartupMessages({
  library(here); library(data.table); library(stringr)
})

# --- Rutas del proyecto -------------------------------------------------------
PATHS <- list(
  raiz       = here::here(),
  datos      = here::here("datos"),
  externos   = here::here("datos", "externos"),
  diccion    = here::here("Diccionarios"),
  crosswalk  = here::here("crosswalk"),
  productos  = here::here("productos"),
  docs       = here::here("docs")
)
invisible(lapply(PATHS, function(p) if (!dir.exists(p)) dir.create(p, recursive = TRUE)))

# --- Parametros del proyecto --------------------------------------------------
PARAMS <- list(
  anio        = 2025L,
  zip_rem     = here::here("SERIE_REM_2025.zip"),  # ZIP del DEIS (raiz del proyecto)
  fecha_datos = "2026-04-24",   # los datos del DEIS son PRELIMINARES: declarar fecha
  meses_mensual   = 1:12,       # series A, BS, BM, D
  meses_semestral = c(6L, 12L), # serie P (stock: junio y diciembre)
  n_cols      = 50L,            # Col01..Col50
  # Prevalencia de demencia por banda etaria (estudio 10/66 Chile; ver FASE_0 sec 3.1)
  prevalencia_60mas = 0.070     # 7,0% global 60+ (urbano 6,3% / rural 10,3%)
)

# Nombres de las columnas de valor (Col01..Col50)
COLS_VALOR <- sprintf("Col%02d", 1:PARAMS$n_cols)

# --- Helpers ------------------------------------------------------------------
# Lee una serie REM desde el ZIP. Multiplataforma (Windows/Mac/Linux): extrae el
# CSV con utils::unzip y lo cachea en datos/ (gitignored); reusa la cache si ya
# existe. Devuelve data.table con TODO como character (NA != 0; el casting a
# numerico se hace explicito aguas abajo).
leer_serie_rem <- function(serie, zip = PARAMS$zip_rem, refrescar = FALSE) {
  archivo <- sprintf("Datos/Serie%s%d.csv", serie, PARAMS$anio)  # ruta dentro del ZIP
  destino <- file.path(PATHS$datos, basename(archivo))
  if (refrescar || !file.exists(destino)) {
    if (!file.exists(zip)) stop("No se encuentra el ZIP REM: ", zip,
                                " (corre 00_descarga.R primero)")
    message("  extrayendo ", basename(archivo), " del ZIP ...")
    utils::unzip(zip, files = archivo, exdir = PATHS$datos, junkpaths = TRUE)
  }
  fread(destino, sep = ";", encoding = "UTF-8",
        colClasses = "character", showProgress = FALSE)
}

# Carga el crosswalk de prestaciones verificado.
cargar_crosswalk <- function() {
  fread(file.path(PATHS$crosswalk, "crosswalk_demencia_prestaciones.csv"),
        encoding = "UTF-8")
}

message("[_setup.R] proyecto: ", PATHS$raiz, " | anio: ", PARAMS$anio)
