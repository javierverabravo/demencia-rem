# =============================================================================
# 09_sintesis.R  ·  Q6 MULTINIVEL: ¿dónde vive la variación? (Fase 5)
# -----------------------------------------------------------------------------
# Barrera de registro: ¿un establecimiento APS registra actividad de demencia
# en un mes dado? (binaria, panel establecimiento x mes, Serie A). Modelo
# logístico de 3 niveles -- establecimiento ⊂ comuna ⊂ región -- para repartir
# la varianza (VPC) y reportar MOR por nivel. Responde si la intervención debe
# ser institucional (varianza en el establecimiento) o territorial (en comuna/
# región). Metodología: rem-estadistica §3-5 (Laplace; ICC latente π²/3 + MOR).
#
# Salidas: productos/multinivel_q6.csv  ·  productos/modelo_estado.csv (append)
# =============================================================================
source(here::here("R", "_setup.R"))
if (!requireNamespace("glmmTMB", quietly = TRUE))
  install.packages("glmmTMB", repos = "https://cloud.r-project.org")
library(glmmTMB)

maestro_rds <- file.path(PATHS$datos, "establecimientos.rds")
if (!file.exists(maestro_rds)) stop("Falta datos/establecimientos.rds (corre 00).")
maestro <- as.data.table(readRDS(maestro_rds))
cw <- cargar_crosswalk()

# --- 1. Universo: establecimientos APS activos x 12 meses --------------------
aps_tipos <- c("Centro de Salud Familiar (CESFAM)", "Posta de Salud Rural (PSR)",
               "Centro Comunitario de Salud Familiar (CECOSF)",
               "Consultorio General Rural (CGR)", "Consultorio General Urbano (CGU)",
               "Centro de Salud")
codigos_A <- cw[serie == "A" & en_universo == "si", codigo_prestacion]  # demencia-especificos

A <- leer_serie_rem("A")
A[, id := IdEstablecimiento]
A[, mes := as.integer(Mes)]
m <- unique(maestro[, .(id = as.character(cod_estab), tipo,
                        comuna = sprintf("%05d", as.integer(cod_comuna)),
                        region = as.character(cod_region),
                        ss = as.character(cod_servicio_salud))])
A <- merge(A, m, by = "id", all.x = TRUE)
aps <- A[tipo %in% aps_tipos]
activos <- unique(aps$id)                       # APS que reportan algo en Serie A
message("Establecimientos APS activos: ", length(activos))

# meses con registro de demencia por establecimiento
dem_obs <- unique(aps[CodigoPrestacion %in% codigos_A, .(id, mes)])
dem_obs[, registro := 1L]

# panel completo establecimiento-activo x mes
uni <- CJ(id = activos, mes = 1:12)
uni <- merge(uni, m, by = "id", all.x = TRUE)
uni <- merge(uni, dem_obs, by = c("id", "mes"), all.x = TRUE)
uni[is.na(registro), registro := 0L]
uni <- uni[!is.na(comuna) & !is.na(region)]
message("Filas panel (estab-mes): ", nrow(uni),
        " | tasa de registro demencia: ", round(100*mean(uni$registro), 1), "%")

# --- 2. Modelo 3 niveles: region / comuna / establecimiento ------------------
ajustar <- function(formula, datos, etiqueta) {
  est <- "no_convergio"; out <- NULL
  tryCatch({
    mod <- glmmTMB(formula, family = binomial, data = datos)
    conv <- mod$fit$convergence == 0 && is.finite(logLik(mod))
    vc <- glmmTMB::VarCorr(mod)$cond
    v <- sapply(vc, function(x) attr(x, "stddev")^2)   # varianzas por nivel
    tot <- sum(v) + pi^2/3                              # + varianza latente logística
    vpc <- round(100 * v / tot, 1)                     # % de varianza por nivel
    mor <- round(exp(sqrt(2 * v) * 0.6745), 2)         # MOR por nivel
    out <- data.table(modelo = etiqueta, nivel = names(v),
                      varianza = round(v, 3), vpc_pct = vpc, MOR = mor,
                      converge = conv)
    est <- if (conv) "ok" else "convergencia_dudosa"
    message("  [", etiqueta, "] ", est, " | VPC: ",
            paste(names(v), vpc, sep="=", collapse="  "), "  (resid latente=",
            round(100*(pi^2/3)/tot,1), "%)")
  }, error = function(e) { est <<- paste0("error: ", conditionMessage(e))
    message("  [", etiqueta, "] ", est) })
  list(tabla = out, estado = est)
}

uni[, `:=`(region = factor(region), comuna = factor(comuna), id = factor(id),
           ss = factor(ss))]

m1 <- ajustar(registro ~ 1 + (1|region) + (1|comuna) + (1|id), uni,
              "region/comuna/establecimiento")
# Alternativo: Servicio de Salud en lugar de region (rem-estadistica §3)
m2 <- ajustar(registro ~ 1 + (1|ss) + (1|comuna) + (1|id), uni,
              "servicioSalud/comuna/establecimiento")

# --- 3. Salidas ---------------------------------------------------------------
res <- rbindlist(list(m1$tabla, m2$tabla), fill = TRUE)
if (nrow(res)) fwrite(res, file.path(PATHS$productos, "multinivel_q6.csv"))
print(res)

estado <- data.table(
  analisis = c("multinivel_q6_principal", "multinivel_q6_alternativo"),
  estado = c(m1$estado, m2$estado))
est_file <- file.path(PATHS$productos, "modelo_estado.csv")
if (file.exists(est_file))
  estado <- rbind(fread(est_file), estado, fill = TRUE)
fwrite(estado, est_file)

message("\n[09] multinivel escrito. LECTURA: si el VPC del establecimiento >> ",
        "comuna+region -> la barrera es INSTITUCIONAL (intervenir centro a centro); ",
        "si comuna/region pesan -> TERRITORIAL. Caveats: escala latente, ",
        "ceros estructurales ya acotados al universo APS activo.")
