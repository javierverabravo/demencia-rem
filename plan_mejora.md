# Plan de mejora priorizado — Demencia en la red pública (Series REM)

Derivado de `auditoria.md` (2026-06-25). Orden por **riesgo primero** (rigor y ética que pueden invalidar conclusiones o exponer personas), luego deuda técnica y entregables, al final lo cosmético. Cada acción indica qué cambiar, por qué, impacto, esfuerzo, la skill de etapa que la ejecuta y, cuando aplica, las **líneas a correr en Positron** (Consola = R; Terminal = git/quarto/shell).

Estas son propuestas; ninguna se ejecuta sin tu aprobación.

---

## Prioridad 1 — Verificar antes de seguir citando

### A1 · Robustecer el denominador de prevalencia (rigor, alto)

**Verificado (2026-06-25).** La tabla de `prev` en `R/03_denominadores.R` coincide **exactamente** con la Tabla 2 de la fuente (Fuentes & Albala 2014, Dement Neuropsychol 8(4):317-322). NO hay error de transcripción. La caída 65-69 (0,041) → 70-74 (0,037) está en la fuente y es ruido muestral; el artículo confirma que la prevalencia crece con la edad (p<0,0001).

**Qué.** El problema no es transcribir mejor sino que el denominador descansa en **una sola encuesta de 2010 por tamizaje** (SENAMA NSD, n=4.860; MMSE<22 + Pfeffer>5), reportada como prevalencias puntuales sin incertidumbre. Tres acciones:
1. **Suavizar la curva por edad** con monotonía impuesta (log-lineal o spline monótono sobre puntos medios), para quitar el bache implausible sin cambiar de fuente.
2. **Triangular con fuentes modeladas y recientes:** GBD/IHME Chile (prevalencia por edad con IC 95%), World Alzheimer Report/ADI, 10/66 pooled América Latina (Rodríguez 2008; Prince et al.). Construir un escenario de denominador por fuente.
3. **Propagar la incertidumbre:** muestrear la prevalencia de su distribución y reportar la brecha como **intervalo** (p. ej. 92-95%), no como 93,7% puntual. Validar externamente los casos esperados (~241 mil 65+) contra GBD y contra la proyección del propio paper (181.761 para 2015).

Decidir además, explícitamente, si se mantiene el alza rural (confundida con escolaridad: OR rural ajustado ~1,4) o se modela vía educación comunal.

**Por qué.** Es el denominador de la rectora y el ancla del eje territorial. Pasar de una encuesta puntual de 2010 a una curva modelada reciente con incertidumbre propagada es el mayor salto de precisión disponible.

**Impacto** alto · **Esfuerzo** medio · **Skill** `investigar-metodo` + `revisar-estado-del-arte` + `ajustar-modelo` + `citar-fuentes`.

Diagnóstico del bache y prueba de suavizado, en la **Consola** de Positron:

```r
source("R/_setup.R")
prev <- data.table::data.table(
  banda      = c("60-64","65-69","70-74","75-79","80-84","85+"),
  edad_mid   = c(62, 67, 72, 77, 82, 90),
  prev_total = c(0.012, 0.041, 0.037, 0.088, 0.194, 0.326))
prev[, salto := c(NA, diff(prev_total))]          # salto negativo = bache (ruido)
# Curva log-lineal monótona como alternativa suavizada
fit <- lm(log(prev_total) ~ edad_mid, data = prev)
prev[, prev_suavizada := exp(predict(fit))]
print(prev)
```

Tras decidir la curva definitiva (suavizada y/o triangulada) y actualizarla en `R/03_denominadores.R`, recalcular y comparar en la **Consola**:

```r
source("R/03_denominadores.R")      # regenera productos/denominadores.csv
source("R/06_analisis_deteccion.R") # regenera brecha y resumen
data.table::fread("productos/deteccion_resumen.csv")
```

---

## Prioridad 2 — Riesgo de divulgación

### A2 · Regla de celdas pequeñas (ética/gobernanza, medio)

**Qué.** Aplicar supresión o redondeo a celdas con conteos bajos en los productos que se publican (`brecha_comuna.csv`, capa de equidad y mapa territorial): por ejemplo, no mostrar tasa comunal cuando el numerador < 5 o la población 65+ < umbral; agregar esas comunas o marcarlas como "n insuficiente". Dejar el caveat en el dashboard.

**Por qué.** Hay comunas con población 65+ de ~20-40 y numerador 0-1 bajo control; cruzadas con composición de pueblos originarios/migrantes, son celdas reidentificables. El origen REM ya es público y agregado, lo que baja la severidad, pero la combinación derivada justifica una política de supresión explícita.

**Impacto** medio · **Esfuerzo** bajo-medio · **Skill** `etica-y-gobernanza-datos` + `preparar-datos` (en el paso de escritura de productos de `06_analisis_deteccion.R` y `08_analisis_equidad.R`).

Diagnóstico rápido en la **Consola** para dimensionar cuántas comunas afecta:

```r
b <- data.table::fread("productos/brecha_comuna.csv")
b[bajo_control_65 < 5, .N]              # comunas con numerador < 5
b[pob_65mas < 50, .(cod_comuna, pob_65mas, bajo_control_65, tasa_deteccion)]
```

---

## Prioridad 3 — Reproducibilidad e integridad del pipeline

### A4 · Fijar entorno y dejar de tragar errores (reproducibilidad, medio-alto)

**Qué.** (a) Inicializar `renv` y capturar el lockfile. (b) En `R/10_run_all.R`, que el `tryCatch` falle ruidosamente (o, mínimo, acumule los fallos y termine con error si alguno es de un script ACTIVO), en vez de imprimir un mensaje y continuar. (c) Opcional mayor: migrar la orquestación a `targets`.

**Por qué.** Sin lockfile, la reproducción depende de las versiones locales. Con el `tryCatch` actual, una corrida con un script roto reporta "completado" igual; eso enmascara fallas.

**Impacto** medio-alto · **Esfuerzo** medio · **Skill** `construir-pipeline-reproducible`.

En la **Consola** (una sola vez, para fijar el entorno):

```r
install.packages("renv")
renv::init()        # detecta dependencias y crea renv.lock
renv::snapshot()    # confirma el lockfile
```

En la **Terminal**, versionar el lockfile:

```bash
git add renv.lock .Rprofile renv/activate.R
git commit -m "Fijar entorno reproducible con renv"
```

### A5 · Resolver los esqueletos del pipeline (coherencia, medio)

**Qué.** Decidir entre dos caminos para `R/04_engine.R` y `R/05_indicadores.R` (ambos son `stop("pendiente")`):
- **Opción limpia (recomendada):** eliminarlos del proyecto y de la lista de `10_run_all.R`, y corregir el README §6 que afirma "motor en `04_engine.R`" (la lógica vive realmente en 06-09).
- **Opción completar:** implementar el motor común y hacer que 06-09 lo usen, para eliminar duplicación.

**Por qué.** Hoy el README documenta una arquitectura (motor común) que no existe; 05 está en el pipeline y solo "falla" en silencio. Es deuda que confunde a quien retome el proyecto.

**Impacto** medio · **Esfuerzo** bajo (opción limpia) / alto (opción completar) · **Skill** `construir-pipeline-reproducible`.

---

## Prioridad 4 — Trazabilidad y entregables

### A8 · Commit del trabajo y bitácora en la historia (trazabilidad, medio)

**Qué.** El árbol está sucio (casi todo modificado, solo dos commits). Confirmar el estado actual con commits que reflejen la bitácora del README, y desde ahora cerrar cada fase con commit como pide el README §7.

**Por qué.** La historia del proyecto vive hoy en una tabla del README, no en git. Sin commits, no hay trazabilidad real ni posibilidad de volver atrás.

**Impacto** medio · **Esfuerzo** bajo · **Skill** transversal de reproducibilidad.

En la **Terminal**:

```bash
git status
git add -A
git commit -m "Cierre Fases 0-6: pipeline, productos, fundamentacion y dashboard"
```

### A6 · Cifras del dashboard leídas del pipeline, no a mano (trazabilidad, medio)

**Qué.** En `deteccion.qmd` (y revisar el resto), reemplazar los valores literales (93,7 %, 94,6 %, 13.114, 205.843) por lectura desde `productos/` en el chunk de R, de modo que el texto se recompute al cambiar los datos.

**Por qué.** `comunicar-resultados` pide que toda cifra salga del pipeline; los literales se desfasan silenciosamente si cambia el denominador (ver A1).

**Impacto** medio · **Esfuerzo** bajo · **Skill** `comunicar-resultados`.

Tras editar los `.qmd`, en la **Terminal**:

```bash
quarto render
```

### A7 · Terminar o retirar `articulo.qmd` (entregable, medio)

**Qué.** El informe técnico PDF es un esqueleto con TODOs. O se completa leyendo de `productos/` y de `FUNDAMENTACION_ESTADISTICA`, o se retira del alcance y el README deja de prometerlo (la fundamentación ya cumple el rol).

**Impacto** medio · **Esfuerzo** medio (completar) / bajo (retirar) · **Skill** `comunicar-resultados`.

---

## Prioridad 5 — Cierre de publicación abierta y contexto

### A3 · Bibliografía verificable + CITATION.cff (citación, medio)

**Qué.** Convertir las referencias de la fundamentación en citas verificables con DOI/URL y, para la prevalencia, página/tabla exacta. Añadir `CITATION.cff` en la raíz para que el propio trabajo sea citable.

**Impacto** medio · **Esfuerzo** bajo-medio · **Skill** `citar-fuentes` + `publicar-abierto`.

### A9 · Licencias por capa y archivo con DOI (publicación, bajo)

**Qué.** Licenciar código (p. ej. MIT), datos derivados y documentos por separado; verificar que no se publique nada sensible (ligado a A2); depositar una versión con DOI (Zenodo/OSF) y metadatos FAIR.

**Impacto** bajo (alto si se busca reutilización académica) · **Esfuerzo** medio · **Skill** `publicar-abierto`.

### A10 · Estado del arte mínimo (rigor/contexto, bajo)

**Qué.** Añadir una sección breve que sitúe el problema (qué se sabe de la brecha de detección de demencia y del registro administrativo en salud) y nombre el encuadre (análisis ecológico, epidemiología de servicios). No requiere revisión sistemática.

**Impacto** bajo · **Esfuerzo** bajo-medio · **Skill** `revisar-estado-del-arte`.

### A11 · Declaración de uso de IA (transversal, bajo-medio)

**Qué.** Añadir una nota de asistencia de IA en los entregables (README y fundamentación), sin tergiversar la autoría; la persona es responsable del contenido.

**Impacto** bajo-medio · **Esfuerzo** trivial · **Skill** transversal.

---

## Secuencia sugerida

1. A1 (verificar prevalencia) → si cambia, recorrer A6 y regenerar productos y render.
2. A2 (celdas pequeñas) antes de cualquier re-publicación.
3. A8 (commit) para fijar el punto de partida; luego A4 (renv + fallar ruidoso).
4. A5, A7 (limpiar pipeline e informe).
5. A3, A9, A10, A11 (cierre de publicación y contexto).

Una corrida de verificación completa, tras los cambios, en la **Consola**:

```r
source("R/10_run_all.R")
```

y en la **Terminal**:

```bash
quarto render
```
