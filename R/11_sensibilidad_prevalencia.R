# =============================================================================
# 11_sensibilidad_prevalencia.R  ·  Triangulacion del denominador (A1 auditoria)
# -----------------------------------------------------------------------------
# La brecha de la rectora depende de UNA sola fuente de prevalencia (10/66 Chile,
# encuesta SENAMA 2010 por tamizaje). Este script NO reemplaza esa decision: la
# pone a prueba. Recalcula la brecha pais y por zona bajo varias curvas de
# prevalencia y propaga incertidumbre, para ver cuanto se mueve el resultado.
#
# Escenarios:
#   (1) 10_66_raw      curva actual del proyecto (Fuentes & Albala 2014, Tabla 2)
#   (2) 10_66_suave    misma fuente, suavizada con monotonia impuesta (quita el
#                      bache 65-69>70-74, que es ruido muestral, no senal)
#   (3) externa_gbd    curva modelada externa (GBD/IHME u otra), OPCIONAL: se lee
#                      de datos/externos/prevalencia_externa.csv si existe.
#
# Incertidumbre: Monte Carlo sobre la prevalencia por banda (lognormal con CV
#   parametrico, por defecto 0.20) -> intervalo 95% de la brecha pais. El CV es
#   un SUPUESTO a reemplazar por los intervalos publicados de GBD cuando se carguen.
#
# El numerador (bajo control 65+ por comuna) es FIJO entre escenarios: solo
# cambia el denominador. Reusa la poblacion comunal x banda del INE (como 03).
#
# Salida: productos/sensibilidad_prevalencia.csv
# Correr DESPUES de 03_denominadores.R y 06_analisis_deteccion.R.
# =============================================================================
source(here::here("R", "_setup.R"))
set.seed(2025)

CV_PREV <- as.numeric(Sys.getenv("REM_CV_PREV", "0.20"))  # incertidumbre relativa
N_MC    <- as.integer(Sys.getenv("REM_N_MC", "2000"))     # repeticiones Monte Carlo

# --- 0. Insumos ---------------------------------------------------------------
ine_xlsx <- file.path(PATHS$externos, "ine_proyecciones_comunas.xlsx")
if (!file.exists(ine_xlsx))
  stop("Falta ", ine_xlsx, " (corre 03_denominadores.R primero).")
bre_file <- file.path(PATHS$productos, "brecha_comuna.csv")
if (!file.exists(bre_file))
  stop("Falta productos/brecha_comuna.csv (corre 06_analisis_deteccion.R primero).")

# numerador fijo + cobertura publica por comuna (de la corrida vigente)
bre <- fread(bre_file, colClasses = list(character = "cod_comuna"))
bre[, cod_comuna := sprintf("%05d", as.integer(cod_comuna))]
den <- fread(file.path(PATHS$productos, "denominadores.csv"),
             colClasses = list(character = "cod_comuna"))
den[, cod_comuna := sprintf("%05d", as.integer(cod_comuna))]
cob <- den[, .(cod_comuna, cobertura_publica)]

# --- 1. Poblacion comunal x banda (misma logica que 03_denominadores.R) -------
crudo <- as.data.table(readxl::read_excel(ine_xlsx, col_names = FALSE, n_max = 15))
fila_hdr <- which(apply(crudo, 1, function(r)
  any(grepl("^edad$", trimws(as.character(r)), ignore.case = TRUE))))[1]
skip_n <- if (is.na(fila_hdr)) 0L else fila_hdr - 1L
ine <- as.data.table(readxl::read_excel(ine_xlsx, skip = skip_n))
setnames(ine, names(ine), trimws(names(ine)))
pick <- function(p) { h <- grep(p, names(ine), ignore.case = TRUE, value = TRUE)
  if (!length(h)) stop("No encuentro columna: ", p); h[1] }
col_comuna <- pick("^comuna$|c[oó]digo.*comuna|^comuna.?cod")
col_edad   <- pick("edad")
col_anio   <- grep(paste0("(^|[^0-9])", PARAMS$anio, "([^0-9]|$)"), names(ine), value = TRUE)[1]
d <- ine[, .(cod_comuna = sprintf("%05d", as.integer(get(col_comuna))),
             edad = suppressWarnings(as.integer(get(col_edad))),
             pob  = suppressWarnings(as.numeric(get(col_anio))))]
d <- d[!is.na(edad) & !is.na(pob)]
banda_de <- function(e) fcase(
  e %in% 60:64, "60-64", e %in% 65:69, "65-69", e %in% 70:74, "70-74",
  e %in% 75:79, "75-79", e %in% 80:84, "80-84", e >= 85, "85+", default = NA_character_)
d[, banda := banda_de(edad)]
pob_cb <- d[!is.na(banda), .(pob = sum(pob)), by = .(cod_comuna, banda)]

# mezcla urbano/rural por comuna
ur_file <- file.path(PATHS$externos, "comunas_urbano_rural.csv")
ur <- if (file.exists(ur_file)) {
  x <- fread(ur_file, colClasses = list(character = "cod_comuna"))
  x[, .(cod_comuna = sprintf("%05d", as.integer(cod_comuna)), prop_rural)]
} else { unique(pob_cb[, .(cod_comuna)])[, prop_rural := NA_real_][] }

# --- 2. Curvas de prevalencia por banda --------------------------------------
edad_mid <- c("60-64"=62,"65-69"=67,"70-74"=72,"75-79"=77,"80-84"=82,"85+"=90)
raw <- data.table(
  banda       = c("60-64","65-69","70-74","75-79","80-84","85+"),
  prev_total  = c(0.012, 0.041, 0.037, 0.088, 0.194, 0.326),
  prev_urbano = c(0.0094,0.039, 0.030, 0.084, 0.172, 0.290),
  prev_rural  = c(0.026, 0.051, 0.069, 0.106, 0.297, 0.504))

# suavizado monotono: ajuste log-lineal por serie sobre la edad media -> creciente
suavizar <- function(prev_vec) {
  x <- edad_mid[c("60-64","65-69","70-74","75-79","80-84","85+")]
  exp(predict(lm(log(prev_vec) ~ x)))
}
suave <- copy(raw)
suave[, prev_total  := suavizar(raw$prev_total)]
suave[, prev_urbano := suavizar(raw$prev_urbano)]
suave[, prev_rural  := suavizar(raw$prev_rural)]

curvas <- list(`10_66_raw` = raw, `10_66_suave` = suave)

# externa (GBD u otra), opcional. Formato CSV: banda,prev_total,prev_urbano,prev_rural
ext_file <- file.path(PATHS$externos, "prevalencia_externa.csv")
if (file.exists(ext_file)) {
  ext <- fread(ext_file)
  if (all(c("banda","prev_total","prev_urbano","prev_rural") %in% names(ext)) &&
      !all(is.na(ext$prev_total))) {
    curvas[["externa_gbd"]] <- ext
    message("Curva externa cargada: ", ext_file)
  } else message("[externa] ", ext_file, " sin columnas/valores validos; se omite.")
} else {
  message("[externa] sin curva externa. Para triangular con GBD, deja ",
          "datos/externos/prevalencia_externa.csv con columnas ",
          "banda,prev_total,prev_urbano,prev_rural (prevalencia por edad de Chile ",
          "del GHDx/IHME, en proporcion 0..1).")
}

# --- 3. Brecha pais y por zona bajo una curva dada ---------------------------
brecha_de_curva <- function(prev) {
  pc <- merge(pob_cb, prev, by = "banda", all.x = TRUE)
  pc <- merge(pc, ur, by = "cod_comuna", all.x = TRUE)
  pc[, prev_ef := fifelse(is.na(prop_rural), prev_total,
                          (1 - prop_rural) * prev_urbano + prop_rural * prev_rural)]
  pc[, esp := pob * prev_ef]
  # esperados 65+ por comuna (excluye 60-64), llevados a poblacion publica
  esp65 <- pc[banda != "60-64", .(esperados_ine = sum(esp)), by = cod_comuna]
  esp65 <- merge(esp65, cob, by = "cod_comuna", all.x = TRUE)
  esp65[, esperados := fifelse(!is.na(cobertura_publica) & cobertura_publica > 0,
                               esperados_ine * cobertura_publica, esperados_ine)]
  z <- merge(esp65, bre[, .(cod_comuna, bajo_control_65, zona)], by = "cod_comuna")
  z <- z[esperados > 0]
  pais <- z[, .(zona = "PAIS", esperados = sum(esperados),
                num = sum(bajo_control_65))]
  porz <- z[!is.na(zona), .(esperados = sum(esperados),
                            num = sum(bajo_control_65)), by = zona]
  out <- rbind(pais, porz, fill = TRUE)
  out[, tasa := num / esperados][, brecha := 1 - tasa]
  out[]
}

# --- 4. Incertidumbre Monte Carlo sobre la brecha pais -----------------------
brecha_pais_mc <- function(prev, cv = CV_PREV, n = N_MC) {
  base_cols <- c("prev_total","prev_urbano","prev_rural")
  vals <- vapply(seq_len(n), function(i) {
    p <- copy(prev)
    for (cc in base_cols) {
      mu <- prev[[cc]]
      # lognormal con media ~ mu y CV dado (sigma en log)
      sdlog <- sqrt(log(1 + cv^2))
      p[[cc]] <- rlnorm(length(mu), meanlog = log(mu) - sdlog^2/2, sdlog = sdlog)
    }
    brecha_de_curva(p)[zona == "PAIS", brecha]
  }, numeric(1))
  quantile(vals, c(0.025, 0.5, 0.975), na.rm = TRUE)
}

# --- 5. Tabla de sensibilidad ------------------------------------------------
res <- rbindlist(lapply(names(curvas), function(nm) {
  b <- brecha_de_curva(curvas[[nm]])
  mc <- tryCatch(brecha_pais_mc(curvas[[nm]]), error = function(e) c(NA,NA,NA))
  pais <- b[zona == "PAIS"]
  data.table(
    fuente        = nm,
    esperados_65  = round(pais$esperados),
    bajo_control  = pais$num,
    tasa_pais     = round(pais$tasa, 3),
    brecha_pais   = round(pais$brecha, 3),
    brecha_lo95   = round(unname(mc[1]), 3),
    brecha_hi95   = round(unname(mc[3]), 3),
    brecha_urbano = round(b[zona=="urbano", brecha], 3),
    brecha_rural  = round(b[zona=="rural",  brecha], 3),
    brecha_mixto  = round(b[zona=="mixto",  brecha], 3))
}), fill = TRUE)

fwrite(res, file.path(PATHS$productos, "sensibilidad_prevalencia.csv"))
print(res)
message("\n[11] sensibilidad escrita. LECTURA: si la brecha pais se mueve poco ",
        "entre 10_66_raw / 10_66_suave / externa_gbd y el intervalo 95% es ",
        "estrecho, la conclusion es robusta al denominador. CV usado=", CV_PREV,
        " (reemplazar por los IC publicados de GBD al cargar la curva externa).")
