# =============================================================================
# 02_datos_comunales.R  ·  Covariables comunales (contexto)  [Fase 4]
# -----------------------------------------------------------------------------
# CASEN pobreza comunal (SAE, auto-descargable) + urbano/rural + geometrias.
# Verificar cruce de comunas contra el REM por codigo unico territorial.
# Salida: productos/comunas.csv (una fila por comuna con covariables).
# =============================================================================
source(here::here("R", "_setup.R"))

# TODO (Fase 4):
#  - CASEN pobreza comunal (Observatorio Social) -> degradar con elegancia si falta
#  - Clasificacion urbano/rural por comuna (ancla del eje territorial)
#  - chilemapas::mapa_comunas para geometrias (Moran/LISA en 09_sintesis.R)
#  - Validar: todas las comunas del REM tienen match (ojo comunas nuevas)
message("[02] PENDIENTE Fase 4: covariables comunales.")
