# =============================================================================
# 07_analisis_cascada.R  ·  Q2 secundaria: Cascada de atención (Fase 5)
# -----------------------------------------------------------------------------
# Embudo AGREGADO de la atención de demencia, nacional y por zona urbano/rural:
#   sospecha (A06) · diagnóstico (A06) · ingreso SM (A05) · bajo control (P6) ·
#   domiciliaria (P3). NO son trayectorias individuales: son registros distintos
#   con lógicas distintas (flujo anual vs stock semestral; marginal vs eje), por
#   lo que NO necesariamente anidan. La lectura es de magnitudes relativas.
# Columnas verificadas (Fase 2): A06 06300100 Col45=sospecha, Col46=diagnóstico.
# Salida: productos/cascada.csv
# =============================================================================
source(here::here("R", "_setup.R"))

num <- function(x) suppressWarnings(as.numeric(x))

# zona por comuna (urbano/rural)
ur <- fread(file.path(PATHS$externos, "comunas_urbano_rural.csv"),
            colClasses = list(character = "cod_comuna"))
ur[, cod_comuna := sprintf("%05d", as.integer(cod_comuna))]
ur[, zona := fifelse(prop_rural >= 0.40, "rural",
              fifelse(prop_rural <= 0.10, "urbano", "mixto"))]

zona_de <- function(dt) {
  dt[, cod_comuna := sprintf("%05d", as.integer(IdComuna))]
  merge(dt, ur[, .(cod_comuna, zona)], by = "cod_comuna", all.x = TRUE)
}

A <- zona_de(leer_serie_rem("A")); A[, mes := as.integer(Mes)]
P <- zona_de(leer_serie_rem("P")); P[, mes := as.integer(Mes)]

# --- Etapas (cada una en su unidad; se declara el caveat) --------------------
etapa <- function(dt, filtro, col) {
  sub <- dt[eval(filtro, dt)]   # evalúa la condición en el scope del data.table
  sub[, val := num(get(col))]
  rbind(
    sub[, .(zona = "PAIS", n = sum(val, na.rm = TRUE))],
    sub[!is.na(zona), .(n = sum(val, na.rm = TRUE)), by = zona]
  )
}
casc <- rbindlist(list(
  cbind(etapa_orden = 1, etapa = "1. Sospecha (A06 consultorías)",
        etapa(A, quote(CodigoPrestacion == "06300100"), "Col45")),
  cbind(etapa_orden = 2, etapa = "2. Diagnóstico (A06 consultorías)",
        etapa(A, quote(CodigoPrestacion == "06300100"), "Col46")),
  cbind(etapa_orden = 3, etapa = "3. Ingreso SM (A05, flujo anual)",
        etapa(A, quote(CodigoPrestacion %in% c("05901801","05901802","05901803")), "Col01")),
  cbind(etapa_orden = 4, etapa = "4. Bajo control (P6, stock dic)",
        etapa(P, quote(mes == 12 & CodigoPrestacion %in% c("P6222300","P6223310")), "Col01")),
  cbind(etapa_orden = 5, etapa = "5. Domiciliaria dep. severa c/demencia (P3, stock dic)",
        etapa(P, quote(mes == 12 & CodigoPrestacion == "P3171613"), "Col01"))
), fill = TRUE)

tab <- dcast(casc, etapa_orden + etapa ~ zona, value.var = "n", fill = 0)
setorder(tab, etapa_orden)
fwrite(tab, file.path(PATHS$productos, "cascada.csv"))
print(tab)

message("\n[07] cascada escrita. LECTURA: las etapas NO anidan (registros con ",
        "lógicas distintas). HALLAZGO: el registro formal de sospecha/diagnóstico ",
        "(A06) es minúsculo frente al ingreso y el bajo control -> el primer paso ",
        "del camino casi no se registra. Caveats: flujo vs stock, no individual.")
