# =============================================================================
# 08_analisis_equidad.R  ·  Q5 secundaria: Equidad (Fase 5)
# -----------------------------------------------------------------------------
# Dos ejes de equidad sobre la brecha de detección:
#  (A) POBREZA: ¿la brecha es mayor en comunas más pobres? (tramo A FONASA =
#      indigencia, ya en denominadores). Eje sólido (datos en mano).
#  (B) PUEBLOS ORIGINARIOS / MIGRANTES: % entre las personas con demencia bajo
#      control (marginales P6, columnas verificadas en Fase 2), por zona.
#      Reglas: marginales INDEPENDIENTES, sin cruces entre sí ni con edad/sexo.
#      Caveat: el peso poblacional comunal (Censo) es el denominador ideal;
#      aquí se reporta la composición del numerador (refinamiento pendiente).
# Salida: productos/equidad_pobreza.csv · productos/equidad_origen.csv
# =============================================================================
source(here::here("R", "_setup.R"))
num <- function(x) suppressWarnings(as.numeric(x))

bre <- fread(file.path(PATHS$productos, "brecha_comuna.csv"),
             colClasses = list(character = "cod_comuna"))

# --- (A) Eje pobreza: brecha por cuartil de indigencia (tramo A) -------------
bp <- bre[!is.na(tramo_a_pct) & esperados > 0]
bp[, cuartil_pobreza := cut(tramo_a_pct, quantile(tramo_a_pct, 0:4/4, na.rm = TRUE),
                            include.lowest = TRUE,
                            labels = c("Q1 menos pobre","Q2","Q3","Q4 más pobre"))]
eq_pob <- bp[, .(
  comunas = .N,
  tramo_a_medio = round(mean(tramo_a_pct), 1),
  bajo_control = sum(bajo_control_65),
  esperados = round(sum(esperados)),
  tasa_deteccion = round(sum(bajo_control_65)/sum(esperados), 3),
  brecha = round(1 - sum(bajo_control_65)/sum(esperados), 3)
), by = cuartil_pobreza][order(cuartil_pobreza)]
rho <- suppressWarnings(cor(bp$tramo_a_pct, bp$tasa_deteccion, method = "spearman",
                            use = "complete.obs"))
fwrite(eq_pob, file.path(PATHS$productos, "equidad_pobreza.csv"))
print(eq_pob)
message("Correlación Spearman tramo_A (pobreza) vs tasa de detección: ", round(rho, 3),
        "  (negativa = más pobre, menos detección)")

# --- (B) Eje pueblos originarios / migrantes: composición del bajo control ---
ur <- fread(file.path(PATHS$externos, "comunas_urbano_rural.csv"),
            colClasses = list(character = "cod_comuna"))
ur[, cod_comuna := sprintf("%05d", as.integer(cod_comuna))]
ur[, zona := fifelse(prop_rural >= 0.40, "rural",
              fifelse(prop_rural <= 0.10, "urbano", "mixto"))]
P <- leer_serie_rem("P")
P[, cod_comuna := sprintf("%05d", as.integer(IdComuna))]
P <- merge(P, ur[, .(cod_comuna, zona)], by = "cod_comuna", all.x = TRUE)
p6 <- P[as.integer(Mes) == 12 & CodigoPrestacion %in% c("P6222300","P6223310")]
# columnas verificadas (Fase 2): PO = Col40+Col41, Migrantes = Col42+Col43, total = Col01
p6[, `:=`(tot = num(Col01),
          po  = num(Col40) + num(Col41),
          mig = num(Col42) + num(Col43))]
agg <- function(by) p6[, .(
  bajo_control = sum(tot, na.rm = TRUE),
  n_pueblos_orig = sum(po, na.rm = TRUE),
  n_migrantes = sum(mig, na.rm = TRUE),
  pct_pueblos_orig = round(100*sum(po, na.rm=TRUE)/sum(tot, na.rm=TRUE), 2),
  pct_migrantes = round(100*sum(mig, na.rm=TRUE)/sum(tot, na.rm=TRUE), 2)
), by = by]
eq_or <- rbind(cbind(zona = "PAIS", agg(NULL)),
               agg("zona")[!is.na(zona)][order(zona)], fill = TRUE)
fwrite(eq_or, file.path(PATHS$productos, "equidad_origen.csv"))
print(eq_or)

message("\n[08] equidad escrita. Eje pobreza: sólido (brecha x cuartil de ",
        "indigencia). Eje origen: composición del bajo control (numerador); el ",
        "denominador poblacional comunal (Censo 2024) es el refinamiento pendiente. ",
        "Recordar: marginales independientes, sin cruces; eje migrante subpotenciado.")
