# =============================================================================
# 01b_panel.R  ·  Panel establecimiento x periodo + cobertura/subregistro (Fase 3)
# -----------------------------------------------------------------------------
# Cruza el universo demencia (crosswalk de prestaciones) con la base maestra de
# establecimientos (00_descarga.R) y reconstruye el panel completo para separar
# CERO ESTRUCTURAL (centro sin el programa por diseno) de SUBREGISTRO (centro
# que deberia registrar y no lo hace). Estructura temporal verificada en Fase 1:
#   A / BS -> mensual (12 periodos) ; P -> semestral (2 periodos: jun, dic).
#
# Salidas:
#   productos/join_diagnostico.csv        tasa de match REM <-> maestro por clave
#   productos/cobertura_subregistro.csv   por bloque x tipo/nivel de establecimiento
# =============================================================================
source(here::here("R", "_setup.R"))

maestro_rds <- file.path(PATHS$datos, "establecimientos.rds")
if (!file.exists(maestro_rds))
  stop("Falta datos/establecimientos.rds. Corre 00_descarga.R primero.")
maestro <- as.data.table(readRDS(maestro_rds))
cw <- cargar_crosswalk()

# --- 1. DIAGNOSTICO DE CRUCE (clave de join REM <-> maestro) ------------------
# El IdEstablecimiento del REM puede corresponder al codigo nuevo o al antiguo
# del DEIS. Probamos ambos y elegimos el de mayor cobertura. ESTO HAY QUE MIRARLO.
ids_rem <- unique(unlist(lapply(c("A","BS","P"), function(s) {
  leer_serie_rem(s)[, unique(IdEstablecimiento)]
})))
m_nuevo   <- mean(ids_rem %in% maestro$cod_estab)
m_antiguo <- if ("cod_estab_antiguo" %in% names(maestro))
               mean(ids_rem %in% maestro$cod_estab_antiguo) else NA_real_
clave <- if (isTRUE(m_antiguo > m_nuevo)) "cod_estab_antiguo" else "cod_estab"
diag <- data.table(
  ids_rem_total = length(ids_rem),
  match_cod_nuevo = round(100*m_nuevo, 1),
  match_cod_antiguo = round(100*m_antiguo, 1),
  clave_elegida = clave
)
fwrite(diag, file.path(PATHS$productos, "join_diagnostico.csv")); print(diag)
if (max(m_nuevo, m_antiguo, na.rm = TRUE) < 0.8)
  warning("Match REM<->maestro < 80%. Revisar codigos (vigentes vs historicos, ",
          "establecimientos cerrados, comunas nuevas) antes de interpretar cobertura.")

# maestro con clave de join homogenea
maestro[, id_join := get(clave)]
mcols <- intersect(c("id_join","tipo","nivel_atencion","dependencia","sistema",
                     "estado","cod_comuna","comuna","cod_region","region",
                     "servicio_salud"), names(maestro))
maestro_j <- unique(maestro[, ..mcols], by = "id_join")

# --- 2. Panel y cobertura/subregistro por bloque -----------------------------
# Para cada codigo de demencia: universo ACTIVO = establecimientos que reportan
# el codigo al menos una vez en el ano. Sobre ese universo:
#   - subregistro temporal = 1 - (periodos observados / periodos esperados)
#   - intensidad = volumen medio (Col01) por establecimiento-periodo activo
# El "cero estructural" se separa cruzando con tipo/nivel (un SAPU no tiene
# poblacion bajo control SM por diseno) y, en Fase 5, con el footprint PND.
panel_bloque <- function(s) {
  periodos <- if (s == "P") PARAMS$meses_semestral else PARAMS$meses_mensual
  keep_cod <- cw$serie == s                     # filtro fuera del scope de data.table
  codigos  <- cw$codigo_prestacion[keep_cod]
  dt <- leer_serie_rem(s)[CodigoPrestacion %in% codigos]
  if (!nrow(dt)) return(NULL)
  dt[, mes := as.integer(Mes)]
  dt[, valor := suppressWarnings(as.numeric(Col01))]
  dt[, id_join := IdEstablecimiento]
  # adjuntar atributos del maestro
  dt <- merge(dt, maestro_j, by = "id_join", all.x = TRUE)
  dt[is.na(tipo), tipo := "(sin match en maestro)"]
  dt[is.na(nivel_atencion), nivel_atencion := "(sin match)"]
  # resumen por bloque (codigo) x tipo x nivel  (serie se agrega despues, es escalar)
  res <- dt[, .(
    establecimientos = uniqueN(id_join),
    periodos_esperados = uniqueN(id_join) * length(periodos),
    periodos_observados = uniqueN(paste(id_join, mes)),
    intensidad_media = round(mean(valor[valor > 0], na.rm = TRUE), 1),
    volumen = sum(valor, na.rm = TRUE)
  ), by = .(codigo = CodigoPrestacion, tipo, nivel_atencion)]
  res[, serie := s]
  res[, subregistro_pct := round(100*(1 - periodos_observados/periodos_esperados), 1)]
  res[]
}
cob <- rbindlist(lapply(c("A","BS","P"), panel_bloque), fill = TRUE)
# enriquecer con descripcion del bloque
cob <- merge(cob, unique(cw[, .(codigo = codigo_prestacion, bloque, descripcion)]),
             by = "codigo", all.x = TRUE)
setcolorder(cob, c("serie","bloque","codigo","descripcion","tipo","nivel_atencion"))
setorder(cob, serie, bloque, codigo, -establecimientos)
fwrite(cob, file.path(PATHS$productos, "cobertura_subregistro.csv"))
print(cob[, .(serie, bloque, tipo, establecimientos, subregistro_pct, intensidad_media)])

message("\n[01b] panel y cobertura escritos en productos/. ",
        "Definir universo esperado (cero estructural) con footprint PND -> Fase 5.")
