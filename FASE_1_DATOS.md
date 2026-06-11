# Fase 1 · Datos — diagnóstico inicial de celdas

> Entregable de la Fase 1 (junio 2026). Caracteriza la mezcla de celdas (% NA / % ceros / % positivos) y la distribución de valores de las series REM 2025, primero global por serie y luego por bloque temático del universo demencia fijado en la Fase 0. Este diagnóstico es el que **decide los modelos de la Fase 3** (exceso de ceros, cola, estructura semestral vs mensual). **No avanza a Fase 2 sin esta caracterización.**
>
> **Fuente:** `SERIE_REM_2025.zip` (DEIS-MINSAL), descargado del proyecto de participación; datos del DEIS **preliminares** (el año en curso y el anterior se actualizan sin aviso). Lectura: CSV separador `;`, UTF-8 con BOM, columnas `Col01…Col50`. Procesamiento por *streaming* desde el ZIP (sin descomprimir a disco). Conteo de celdas sobre las 50 columnas `Col`; filtrado del universo demencia por `CodigoPrestacion` exacto (códigos verificados en `FASE_0_INSTRUMENTO.md`).

---

## 1. Mezcla de celdas global por serie (REM 2025)

Conteo sobre las 50 columnas `Col01…Col50` de todas las filas de cada serie.

Cifras canónicas: salida de `R/01_procesamiento.R` con `data.table::fread()` (corrida en Positron). _Nota de reproducibilidad: una estimación previa por línea de comandos (`awk`) difería ~2 pp en el reparto NA↔cero porque trataba el `\r` final de los CSV CRLF como un cero en la última columna; el parser de `fread` lo maneja bien. El `% positivos` no se vio afectado._

| Serie | Archivo | Filas | % NA | % ceros | % positivos |
|---|---|---:|---:|---:|---:|
| **A** (atenciones) | `SerieA2025.csv` | 7.126.859 | 67,0 | 17,2 | 15,8 |
| **BS** (prestaciones trazadoras) | `SerieBS2025.csv` | 1.050.345 | 72,8 | 17,6 | 9,6 |
| **BM** (prestaciones municipal) | `SerieBM2025.csv` | 780.872 | 95,4 | 1,0 | 3,6 |
| **P** (población bajo control) | `SerieP2025.csv` | 1.245.039 | 64,6 | 15,0 | 20,3 |
| **D** (programas, PACAM) | `SerieD2025.csv` | 329.381 | 91,7 | 0,9 | 7,4 |

### Lectura del % NA (importante para no malinterpretar el subregistro)

El **% NA es alto en todas las series porque está dominado por columnas estructuralmente no usadas**, no por subregistro. Cada sección del REM usa solo un puñado de las 50 columnas `Col` disponibles (algunas 2-3, otras 20-30); el resto queda vacío **por diseño del formulario**. Por eso BM (formularios estrechos) llega a 93 % NA y P (formularios anchos, columnas etarias × sexo) baja a 63 %. **El NA de celda ≠ subregistro.** El subregistro real —establecimientos-mes que debieron registrar y no lo hicieron— vive en las **filas que no existen**, y se mide reconstruyendo el panel completo establecimiento × mes (Fase 3), no contando celdas vacías.

> **Nota sobre la cifra de referencia.** La skill `rem-datos` cita para Serie A 2025 ≈ 39 % NA / 24 % ceros / 37 % positivos; aquí da 65 / 19 / 16 sobre las 50 columnas. La diferencia es de **alcance de columnas**: la referencia pondera el subconjunto de columnas efectivamente en uso, mientras este conteo incluye las 50 (con la cola de columnas vacías por diseño). Ambas son correctas; conviene reportar la mezcla **por sección** (sobre las columnas vivas de cada bloque) para el análisis, que es lo que hace la §2.

---

## 2. Diagnóstico por bloque temático del universo demencia

Filas extraídas por `CodigoPrestacion` exacto. `est` = nº de establecimientos distintos que registran el código en el año. `%NA/%0/%pos` sobre las 50 `Col`. `sumTot` = suma de todas las celdas (volumen anual del código). `med`/`máx` = mediana y máximo de la **suma por fila** (carga por establecimiento-mes).

### 2.1 Serie A — atenciones mensuales (12 meses presentes, ene-dic)

| Código | Bloque | Filas | Est. | %NA | %0 | %pos | Volumen | Med | Máx |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| `05901801/02/03` | A05 **ingresos** SM por demencia (Leve/Mod/Avz) | 7.224 | — | ~65 | ~27 | ~8 | 45.771 | 3 | 104 |
| `05224201/02/03` | A05 **egresos** SM por demencia (Leve/Mod/Avz) | 3.037 | — | ~71 | ~23 | ~6 | 16.860 | 3 | 224 |
| `06906135` | A06-F reeval. deterioro **GDS Reisberg** | 773 | 143 | 85,0 | 4,6 | 10,4 | 24.700 | 15 | 513 |
| `06906140` | A06-F **cuidador**: reeval. sobrecarga | 315 | 68 | 85,1 | 4,6 | 10,3 | 6.677 | 12 | 128 |
| `06906145` | A06-F **cuidador**: satisfacción usuaria | 96 | 22 | 84,4 | 4,8 | 10,9 | 2.421 | 18 | 81 |
| `19201021` | A19a familia con integrante con demencia | 2.492 | 585 | 98,0 | 0,0 | 2,0 | 25.732 | 2 | 445 |
| `26411010` | A26 dep. severa por cond. asociadas (**total eje**) | 10.210 | 1.567 | 81,8 | 9,3 | 8,8 | 209.361 | 9 | 1.075 |
| `26411011` | A26 dep. severa terminal (excl. demencia avz.) | 5.784 | 1.207 | 82,1 | 10,6 | 7,3 | 65.112 | 5 | 696 |
| `26411012` | A26 dep. severa **sin** diagnóstico de demencia | 13.115 | 1.754 | 81,7 | 8,8 | 9,5 | 403.429 | 13 | 2.399 |
| `28201001` | A28 dx **Alzheimer y otras demencias** | 1.239 | 441 | 67,9 | 22,1 | 9,9 | 10.290 | 4 | 120 |
| `28022300` | A28 estimulación cognitiva | 7.210 | 974 | 96,4 | 1,1 | 2,5 | 232.040 | 11 | 1.013 |
| `28021500` | A28 estimulación cognitiva (2) | 1.362 | 139 | 98,0 | 0,0 | 2,0 | 488.739 | 135 | 3.947 |
| `28020840/00` | A28 cuidadores | 678 | — | ~91 | ~3 | ~6 | 14.878 | 12 | ~900 |

### 2.2 Serie BS — prestaciones trazadoras (12 meses presentes)

| Código | Bloque | Filas | Est. | %NA | %0 | %pos | Volumen | Med | Máx |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| `01010053` | BS evaluación cognitiva | 498 | 65 | 73,9 | 17,2 | 8,9 | 145.591 | 84 | 13.632 |
| `01010054` | BS estimulación cognitiva | 591 | 81 | 73,8 | 17,3 | 8,9 | 404.100 | 224 | 9.924 |
| `01010916` | BS evaluación de funciones cognitivas | 674 | 79 | 74,1 | 16,7 | 9,3 | 278.492 | 132 | 9.864 |

### 2.3 Serie P — población bajo control (stock semestral: solo meses 6 y 12)

| Código | Bloque | Filas | Est. | %NA | %0 | %pos | Volumen | Med | Máx |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| `P6222300` | P6 bajo control SM **Demencias (incl. Alzheimer)** | 2.135 | 1.224 | 59,3 | 26,5 | 14,3 | 83.857 | 14 | 676 |
| `P6223310` | P6 bajo control SM Demencias (sección hermana) | 175 | 110 | 54,3 | 28,4 | 17,2 | 9.208 | 15 | 468 |
| `P3171613` | P3 dep. severa domiciliaria **Con Demencia** | 2.521 | 1.413 | 59,7 | 26,7 | 13,7 | 137.118 | 21 | 905 |

---

## 3. Hallazgos que condicionan el análisis

1. **Estructura temporal confirmada (anclaje del panel, Fase 3).** Serie A y BS traen los **12 meses** (atenciones/prestaciones mensuales); Serie P aparece **solo en los meses 6 y 12** (stock semestral, junio y diciembre). Esto valida la decisión del README: P se modela como tasa con corte semestral, A/BS como conteos mensuales. No se mezclan en una sola plantilla.

2. **`P6222300` es el numerador limpio de la pregunta rectora.** 1.224 establecimientos lo registran, en ambos cortes (jun 1.049 / dic 1.086). Es el "Demencias (incluye Alzheimer)" de población bajo control SM, con columnas etarias × sexo → 65+ aislable. `P6223310` es una **sección hermana mucho menor** (110 establecimientos, 9.208 personas-celda): registro marginal/duplicado a discriminar en Fase 2 antes de sumar (riesgo de doble conteo).

3. **Exceso de ceros + cola larga en casi todos los bloques de Serie A.** Sobre las columnas vivas, los conteos por establecimiento-mes tienen mediana baja (2-15) y máximos muy altos (445, 1.075, 2.399, 3.947). Es el patrón clásico **conteo con sobredispersión y exceso de ceros** → la Fase 3 deberá evaluar **hurdle dos partes / binomial negativa** (no Poisson simple) para los bloques de Serie A. Decisión se confirma en Fase 3 con el panel, no aquí.

4. **A06 Secc. F (núcleo del PND) tiene cobertura muy baja — subregistro confirmado.** `06906135` solo en 143 establecimientos, `06906140` en 68, `06906145` en 22. Coincide con lo anticipado en Fase 0 (sección nueva → alto subregistro). Refuerza relegar la pregunta de **cuidadores (Q4)** a exploratoria y leer las evaluaciones PND con cautela.

5. **A19a (`19201021`) es casi todo NA (98 %).** Usa solo las columnas-total (Col01-02): conteo grueso de familias, sin edad ni sexo. Sirve de contexto, no de numerador desagregable.

6. **Serie A26: la demencia se obtiene por diferencia, no directamente.** El eje registra dependencia severa **con vs sin** demencia (`26411012` = *sin* demencia; `26411010` = total del eje). El conteo "con demencia" es `total − sin demencia`, vía familia/PADDS, no un registro directo de personas. Tratar como aproximación domiciliaria, con caveat.

7. **Serie B — doble codificación resuelta.** En el diccionario la columna A trae `0101xxxx` y la columna B un código hermano (`5099063`, etc.). **El CSV usa el código de la columna A** (`01010053/54/916` aparecen literalmente como `CodigoPrestacion`); el `5099xxx` es solo la codificación alterna del diccionario. Queda cerrado el pendiente que la Fase 0 dejó para la Fase 2.

8. **Volumen concentrado en estimulación cognitiva.** `28021500` (1.362 filas, 139 establecimientos) concentra 488.739 atenciones-celda con mediana 135 por fila: pocos centros, alta intensidad → distribución muy asimétrica, candidata a tratamiento aparte en el bloque rehabilitación/BS.

---

## 4. Implicaciones para la Fase 3 (modelado)

- **Conteos mensuales (A, BS):** anticipar **exceso de ceros + sobredispersión**; el modelo más simple que ajuste manda, pero la cola observada empuja hacia hurdle/binomial negativa. Confirmar con el panel completo (separar cero estructural de subregistro por tipo de establecimiento).
- **Stock semestral (P):** tasas con denominador etario (INE 65+) y offset; panel establecimiento × semestre; comparación junio–diciembre. `P6222300` como numerador, evitando sumar `P6223310` sin antes verificar que no duplica.
- **El % NA de celda NO es la métrica de subregistro.** El subregistro se mide en Fase 3 sobre el panel (combinaciones establecimiento-mes esperadas sin fila), cruzado con tipo/nivel de establecimiento.

---

## 5. Pendientes que esta fase deja amarrados para la Fase 2

- **Crosswalk de columnas:** fijar el índice `Col` exacto de los grupos etarios 65+ y de las marginales **Pueblos Originarios / Migrantes** en P6, P3, A05 y A06 (presencia confirmada en Fase 0; falta la posición de columna). Imprescindible para aislar el numerador 65+ de la rectora y la lectura de equidad (Q5).
- **`P6223310` vs `P6222300`:** discriminar si la sección hermana suma o duplica antes de construir el numerador.
- **Marginales "Demencia" en A06-controles y A32:** son **columnas** dentro de secciones SM más amplias, no códigos propios; resolver en el crosswalk de columnas (no aparecen como filas en este diagnóstico).
- **A26 "con demencia" por diferencia:** documentar la fórmula `total − sin demencia` en el crosswalk con su caveat.
- **Base maestra de establecimientos del DEIS** (tipo, nivel, dependencia, comuna, Servicio de Salud) para la reconstrucción del panel y el cálculo de cobertura/subregistro (Fase 3).

---

## 6. Bitácora de decisiones (añadir al README §8)

| Fecha | Decisión | Razón |
|---|---|---|
| 2026-06-10 | **Fase 1 cerrada** (ver `FASE_1_DATOS.md`): mezcla de celdas caracterizada global y por bloque demencia | Diagnóstico base para decidir modelos en Fase 3 |
| 2026-06-10 | El **% NA de celda no se usará como métrica de subregistro** | Está dominado por columnas estructuralmente vacías; el subregistro se mide sobre el panel (filas faltantes) en Fase 3 |
| 2026-06-10 | Estructura temporal verificada en el dato: A/BS mensuales (12 meses), **P semestral (jun/dic)** | Confirma panel mensual vs semestral; no forzar plantilla única |
| 2026-06-10 | **Doble codificación Serie B resuelta**: el CSV usa el código col-A `0101xxxx` | `01010053/54/916` presentes como `CodigoPrestacion`; `5099xxx` es alterna del diccionario |
| 2026-06-10 | `P6222300` confirmado como numerador limpio; `P6223310` a discriminar antes de sumar | Sección hermana menor (110 estab.); riesgo de doble conteo |
| 2026-06-10 | Q4 cuidadores se mantiene exploratoria; A06-F con cobertura muy baja (22-143 estab.) | Subregistro confirmado en datos, como anticipó la Fase 0 |
