# =============================================================================
# 00_descarga.R  ·  Obtencion de insumos crudos
# -----------------------------------------------------------------------------
# - Verifica/descarga el ZIP REM del DEIS (preliminar: declarar fecha).
# - (TODO Fase 3/4) Descarga la base maestra de establecimientos del DEIS y la
#   cachea como .rds para la reconstruccion del panel.
# Salidas: SERIE_REM_2025.zip en la raiz; datos/establecimientos.rds (pendiente).
# =============================================================================
source(here::here("R", "_setup.R"))

# --- 1. ZIP REM ---------------------------------------------------------------
url_rem <- sprintf(
  "https://repositoriodeis.minsal.cl/DatosAbiertos/REM/SERIE_REM_%d.zip",
  PARAMS$anio
)
if (!file.exists(PARAMS$zip_rem)) {
  message("Descargando REM ", PARAMS$anio, " (~150 MB) desde el DEIS...")
  options(timeout = 1800)
  download.file(url_rem, PARAMS$zip_rem, mode = "wb")
} else {
  message("ZIP REM ya presente: ", PARAMS$zip_rem,
          "  (datos preliminares al ", PARAMS$fecha_datos, ")")
}

# Listado de contenido (sanidad) — multiplataforma
contenido <- utils::unzip(PARAMS$zip_rem, list = TRUE)
print(contenido[, c("Name", "Length")])

# --- 2. Base maestra de establecimientos (DEIS) -------------------------------
# Establecimientos de Salud vigentes (datos.gob.cl, Ministerio de Salud, CC-Zero).
# Usamos la URL de "datastore dump" (estable, no cambia con la fecha del archivo;
# el dataset se actualiza ~mensual). Separador detectado por fread; BOM incluido.
maestro_rds <- file.path(PATHS$datos, "establecimientos.rds")
maestro_csv <- file.path(PATHS$datos, "establecimientos.csv")
url_estab <- "https://datos.gob.cl/datastore/dump/2c44d782-3365-44e3-aefb-2c8b8363a1bc?bom=True"

if (!file.exists(maestro_rds)) {
  if (!file.exists(maestro_csv)) {
    message("Descargando base maestra de establecimientos (DEIS / datos.gob.cl)...")
    options(timeout = 600)
    download.file(url_estab, maestro_csv, mode = "wb")
  }
  est <- fread(maestro_csv, encoding = "UTF-8", colClasses = "character",
               showProgress = FALSE)
  setnames(est, names(est), trimws(names(est)))
  # Columnas clave (la base trae ~30 columnas). Seleccion + rename a nombres limpios.
  ren <- c(
    EstablecimientoCodigo                   = "cod_estab",
    EstablecimientoCodigoAntiguo            = "cod_estab_antiguo",
    EstablecimientoGlosa                    = "nombre",
    TipoEstablecimientoGlosa                = "tipo",
    NivelAtencionEstabglosa                 = "nivel_atencion",
    NivelComplejidadEstabGlosa              = "complejidad",
    DependenciaAdministrativa               = "dependencia",
    TipoSistemaSaludGlosa                   = "sistema",        # Publico / Privado / ...
    EstadoFuncionamiento                    = "estado",
    ComunaCodigo                            = "cod_comuna",
    ComunaGlosa                             = "comuna",
    RegionCodigo                            = "cod_region",
    RegionGlosa                             = "region",
    "SeremiSaludCodigo_ServicioDeSaludCodigo" = "cod_servicio_salud",
    "SeremiSaludGlosa_ServicioDeSaludGlosa"   = "servicio_salud"
  )
  hay <- intersect(names(ren), names(est))
  est <- est[, ..hay]
  setnames(est, hay, ren[hay])
  saveRDS(est, maestro_rds)
  message("  maestro cacheado: ", maestro_rds, "  (", nrow(est), " establecimientos)")
} else {
  message("Maestro de establecimientos ya cacheado: ", maestro_rds)
}
