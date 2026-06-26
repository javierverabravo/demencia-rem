# Demencia en la red pública de salud · Series REM Chile

### 🔗 [**Ver el dashboard en vivo →**](https://javierverabravo.github.io/demencia-rem/)

📄 [**Fundamentación estadística (PDF)**](FUNDAMENTACION_ESTADISTICA.pdf) · 🗺️ [Mapa territorial](https://javierverabravo.github.io/demencia-rem/territorio.html) · 📊 [Las 4 preguntas](https://javierverabravo.github.io/demencia-rem/deteccion.html)

> Análisis de la detección, atención y carga de demencia en la red pública chilena, en población general con énfasis en personas mayores (65+), con mirada territorial (urbano/rural, comunal) e identificación de focos. Replica la metodología validada del proyecto de participación ciudadana (REM-A19b) mediante las skills `rem-datos`, `rem-estadistica` y `rem-pipeline-quarto`.
>
> **Estado:** Fases 0-6 completas (junio 2026). Dashboard publicado en GitHub Pages. Análisis reproducible de punta a punta (`source("R/10_run_all.R")` + `quarto publish gh-pages`).

**Hallazgos principales:** brecha de detección de demencia 65+ = **93,7%** (1 de cada 16 personas esperadas está bajo control SM público); la detección urbana es ~1,7× la rural; la variación es **predominantemente institucional** (el establecimiento explica el 53% — MOR 16); donde está el Plan Nacional de Demencia (Osorno, Punta Arenas) la detección sube. Detalle y caveats en el [dashboard](https://javierverabravo.github.io/demencia-rem/) y la [fundamentación](FUNDAMENTACION_ESTADISTICA.pdf).

---

## 1. Las preguntas (menú candidato — la rectora se elige DESPUÉS de la Fase 0)

La pregunta más relevante no la determinan los datos sino el uso del análisis; los datos determinan cuáles son respondibles. Candidatas, en orden de potencial para política pública:

1. **Brecha de detección** *(probablemente la rectora)*: comparar población bajo control por demencia (Serie P) contra la prevalencia esperada por edad en cada comuna → ¿cuánta demencia esperada está fuera del sistema y dónde?
2. **Cascada de atención**: sospecha (A06) → confirmación/ingreso (A05) → bajo control (P) → atención domiciliaria (A26). ¿Dónde se pierde la gente entre etapas?
3. **Equidad en la implementación** del Plan Nacional de Demencia: qué comunas tienen el programa y si el despliegue favorece a las mejor dotadas.
4. **Cuidadores**: sobrecarga (Zarit, A03) y evaluaciones del PND (A06 secc. F) — dimensión poco analizada.
5. **Equidad étnica y migrante**: participación de pueblos originarios y migrantes en la detección y atención de demencia (EMPAM, sospecha, bajo control, PND), comparada contra su peso poblacional comunal. ¿Acceden menos? ¿En qué territorios? El A06 ya trae estas columnas (verificar el resto en Fase 0). Lección del proyecto A19b: estas columnas son **marginales independientes** — el análisis es por sección, sin cruces con otras variables.
6. **¿Dónde vive la variación?** (institucional vs territorial, heredada del proyecto A19b): válida pero aquí probablemente secundaria.

### Lo que el REM NO puede responder (declarar siempre)

Prevalencia real (solo ve a quienes contactan el sistema), nada a nivel individual, sin resultados clínicos (progresión, mortalidad), sin causalidad ni efectividad. Las desagregaciones (sexo, edad, pueblos originarios) son columnas marginales independientes: no se pueden cruzar entre sí.

---

## 2. Dónde vive la demencia en el REM 2025 (POR VERIFICAR contra el manual)

Resultado de búsqueda de texto en los diccionarios 2025 (junio 2026). La **Fase 0 consiste en verificar cada fila** de esta tabla contra el Manual REM y el diccionario de su serie (secciones, columnas, reglas de consistencia).

| Serie | Formulario | Qué hay | Códigos vistos |
|---|---|---|---|
| A | A03 | EMPAM (detección preventiva); Zarit abreviado (sobrecarga cuidador, secc. D.6); Yesavage GDS-15 | 09600226… |
| A | A05 | Ingresos/egresos salud mental por "Demencias (Incluye Alzheimer)"; secc. K/L adulto mayor según funcionalidad | 05901801, 05224201, 05021207, 05050700 |
| A | A06 | "Personas con sospecha de demencia"; **Secc. F: Evaluaciones Plan Nacional de Demencia** (GDS Reisberg, sobrecarga y satisfacción de cuidadores) | 06906135, 06906140, 06906145 |
| A | A19a | Familias "con integrante con demencia" | 19201021 |
| A | A26 | Atención domiciliaria: dependencia severa con/sin demencia | 26411010-12 |
| A | A27 | Yesavage GDS-15 | 29101573, 29101581 |
| A | A28 | "Alzheimer y otras demencias" | 28201001 |
| A | A32 | Variables de demencia (varias secciones) | 321006xx-321008xx |
| BS | B | Evaluación/estimulación/rehabilitación cognitiva; "Atención integral en demencia" | 01010053-62, 01010916-38 |
| P | P3 | Población bajo control adulto mayor "Con Demencia" | P3171613 |
| P | P6 | Población bajo control salud mental "Demencias (incluye Alzheimer)" | P6222300, P6223310 |
| D | D16 | PACAM (contextual adulto mayor) | — |

Implicación de diseño: el tema cruza **varias series con lógicas distintas** — atenciones mensuales (A), prestaciones (BS), stock semestral (P). Cada bloque se analiza en su propia lógica; no forzar una plantilla única.

---

## 3. Denominadores y fuentes externas

| Fuente | Uso | Acceso |
|---|---|---|
| Proyecciones INE edad × comuna | Denominador etario 65+/60+ (el principal del proyecto) | INE, descargable |
| Prevalencia esperada de demencia por edad | Brecha de detección (pregunta 1) | Literatura (buscar y citar en Fase 0) |
| FONASA inscritos validados | Denominador per cápita alternativo | CSV manual en `datos/externos/` |
| CASEN pobreza comunal (SAE) | Covariable contextual | Auto-descargable |
| Listado comunas/establecimientos PND | Delimitar universo del programa (pregunta 3) | MINSAL (buscar en Fase 0) |
| Población indígena y migrante por comuna | Denominador de equidad (pregunta 5) | Censo 2024 / CASEN / Estimaciones SJM-INE (definir en Fase 0) |
| `chilemapas` | Geometrías comunales, mapas, Moran/LISA | CRAN |

---

## 4. Decisiones metodológicas anticipadas

Lo **invariante** (aplica siempre, de las skills): panel completo, NA ≠ 0, ceros estructurales vs subregistro, verificación de convergencia, caveats declarados.

Lo **condicionado al diagnóstico** (decidir en Fase 3, no antes):

- Serie A/BS (conteos mensuales): hurdle dos partes **solo si** hay exceso de ceros y cola extrema; si no, Poisson/binomial negativa mixta. El modelo más simple que ajuste es el correcto.
- Serie P (stock semestral): NO es conteo mensual → tasas con denominador etario (Poisson con offset / binomial), panel establecimiento × semestre, comparación junio–diciembre.
- Plan Nacional de Demencia: implementación gradual → delimitar primero dónde existe el programa, o se confundirá "no implementado" con subregistro.
- Focos territoriales: Moran global + LISA sobre tasas comunales (alto-alto y bajo-bajo); urbano/rural como estratificador descriptivo y covariable.
- Pregunta multinivel: establecimiento ⊂ comuna ⊂ región con ICC + MOR, probando Servicio de Salud como nivel alternativo.

---

## 5. Plan de trabajo por fases

| Fase | Qué se hace | Entregable |
|---|---|---|
| **0. Instrumento** | Verificar tabla §2 contra Manual REM + diccionarios; buscar prevalencia por edad y listado PND; **elegir pregunta rectora** | Tabla verificada + pregunta rectora + 2-3 secundarias |
| **1. Datos** | Descargar/copiar ZIP REM; caracterizar celdas (% NA/ceros/positivos) por serie y bloque | Diagnóstico inicial de celdas |
| **2. Crosswalks** | `crosswalk_demencia_prestaciones.csv` y `crosswalk_demencia_columnas.csv`, validados (ver `crosswalk/NOTAS.md`) | Crosswalks versionados |
| **3. Panel y diagnóstico** | Panel establecimiento × mes (A/BS) y × semestre (P); cobertura/subregistro/intensidad por tipo de establecimiento; **decidir modelos** según estructura observada | Diagnóstico + decisión de modelos |
| **4. Denominadores** | INE 65+, FONASA, CASEN, PND; verificar cruce comunal | Tablas de contexto |
| **5. Análisis** | Motor común por bloque: brecha de detección, cascada, focos LISA, multinivel, cuidadores | `productos/` por bloque |
| **6. Productos** | Dashboard Quarto pedagógico (página Territorio con mapa) + informe técnico + README-historia | Sitio en GitHub Pages + PDF |

Regla de avance: ninguna fase de modelado empieza sin la anterior; la Fase 0 puede matar o cambiar preguntas — eso es éxito, no retraso.

---

## 6. Estructura prevista del repositorio

```
PROYECTO DEMENCIA REM/
├── R/                   00_descarga … 10_run_all (motor en 04_engine.R)
├── crosswalk/           crosswalks curados a mano (SE VERSIONAN) — ver NOTAS.md
├── datos/               crudos + externos/ (en .gitignore)
├── productos/           salidas CSV; lo ÚNICO que leen dashboard e informe
├── index.qmd            dashboard → docs/ (GitHub Pages)
├── articulo.qmd         informe técnico → PDF
├── _quarto.yml · custom.scss
├── README.md            este documento (se convierte en la historia del proyecto)
└── FUNDAMENTACION_ESTADISTICA.md   (se escribe junto con la Fase 5)
```

---

## 7. Instrucciones de ejecución

### Preparación (una sola vez)

1. Mover esta carpeta a su ubicación definitiva (p. ej. `E:\PROYECTO DEMENCIA REM`).
2. Copiar desde el proyecto de participación: la carpeta `Diccionarios/` y los manuales PDF → a `datos/` de este proyecto. Opcional: el ZIP `SERIE_REM_2025.zip` (ahorra ~150 MB de descarga).
3. Verificar que las 3 skills estén instaladas (Settings > Capabilities): `rem-datos`, `rem-estadistica`, `rem-pipeline-quarto`.
4. Abrir nueva sesión de Cowork seleccionando esta carpeta. Las skills se activan solas con pedidos en lenguaje natural; si una no se activa, nombrarla ("usa la skill rem-datos").
5. Al cerrar cada fase: registrar la decisión en la bitácora (§8) y hacer commit.

### Instrucciones por fase (cada bloque sirve de prompt para la sesión)

**Fase 0 — Instrumento.** Verificar cada fila de la tabla §2 contra el Manual REM 2025-2026 y el diccionario de su serie: confirmar sección, códigos, qué mide cada columna y las reglas de consistencia; descartar las filas que no correspondan. **Mapear qué secciones traen columnas de pueblos originarios y migrantes** (el A06 las tiene; verificar A03/EMPAM, A05, P3, P6) — insumo de la pregunta de equidad. Buscar en la literatura tasas de prevalencia de demencia por grupo de edad aplicables a Chile (citar fuente), el listado oficial de comunas/establecimientos del Plan Nacional de Demencia, y definir la fuente de población indígena/migrante comunal. Con eso, evaluar la factibilidad de las 6 preguntas del §1 y proponer pregunta rectora + 2-3 secundarias. **No avanzar a Fase 2 sin la tabla verificada.**

**Fase 1 — Datos.** Descargar (o usar el ZIP copiado) las series REM; leer con `data.table::fread(encoding="UTF-8")`, separador `;`. Caracterizar por serie y bloque temático: nº de filas, % NA / % ceros / % positivos, distribución (mediana, máximos, cola). Este diagnóstico decide los modelos en Fase 3.

**Fase 2 — Crosswalks.** Construir `crosswalk_demencia_prestaciones.csv` (CodigoPrestacion → serie/formulario/sección/bloque + descripción) y `crosswalk_demencia_columnas.csv` (sección × Col01…Col50 → qué mide; en Serie P las columnas suelen ser grupos de edad — clave para aislar 65+). Validar: totales reconstruidos ≈ columna total; ningún código vigente del diccionario fuera del crosswalk; revisar códigos del CSV ausentes del diccionario. Versionar en `crosswalk/`.

**Fase 3 — Panel y diagnóstico.** Con la base maestra de establecimientos (tipo, nivel, dependencia, comuna, Servicio de Salud), reconstruir panel establecimiento × mes (A/BS) y establecimiento × semestre (P). Calcular cobertura, subregistro e intensidad por tipo de establecimiento. Separar ceros estructurales (tipo de centro sin el programa; comuna sin PND) de subregistro real. Con la estructura observada, **decidir los modelos** según la guía de decisión de `rem-estadistica` (sección 0) y registrarlo en la bitácora.

**Fase 4 — Denominadores.** Descargar proyecciones INE por edad y comuna (construir población 65+ y 60+ comunal); cargar FONASA si está disponible (degradar con elegancia si no); CASEN SAE; listado PND. Verificar cruce comunal de cada fuente contra el REM por código único territorial.

**Fase 5 — Análisis.** Armar el motor común (`04_engine.R`) y correrlo por bloque: (a) brecha de detección = bajo control P vs prevalencia esperada × población 65+, por comuna, con mapa y LISA; (b) cascada sospecha → ingreso → bajo control → domiciliaria; (c) multinivel con ICC+MOR sobre la barrera de registro; (d) cuidadores (Zarit, secc. F del A06); (e) equidad marginal: % pueblos originarios y % migrantes por sección y etapa de la cascada, comparado contra su peso poblacional comunal, con lectura territorial (¿dónde la brecha étnica/migrante es mayor?). Recordar: análisis marginal por sección, nunca cruces entre columnas marginales. Verificar convergencia de todo modelo antes de interpretar (`productos/modelo_estado.csv`). Escribir `FUNDAMENTACION_ESTADISTICA.md` en paralelo.

**Fase 6 — Productos.** Pipeline completo reproducible (`source("R/10_run_all.R")` + `quarto render`); dashboard pedagógico (orden: Metodología → Glosario → Resumen → Territorio → bloques → Síntesis → Robustez; glosario con doble definición; mapa leaflet con selector); informe técnico PDF; convertir este README en la historia del proyecto (incluyendo lo descartado y los resultados nulos).

## 8. Bitácora de decisiones

| Fecha | Decisión | Razón |
|---|---|---|
| 2026-06 | Proyecto creado; mapa inicial de códigos desde diccionarios | Búsqueda de texto, pendiente verificación |
| 2026-06 | Pregunta rectora pospuesta a fin de Fase 0 | La relevancia depende del uso; la factibilidad, de los datos |
| 2026-06 | Foco de equidad agregado: pueblos originarios y migrantes | Pedido de Javier; el REM lo soporta como columnas marginales (sin cruces) |
| 2026-06-09 | **Fase 0 cerrada** (ver `FASE_0_INSTRUMENTO.md`): tabla §2 verificada código a código contra diccionarios 2025 | Todos los códigos existen; correcciones: A05 `05021207`/`05050700` son EMPAM (no demencia); A27 (`291015xx`) es Yesavage/depresión → fuera del universo; P3 "Con Demencia" es subgrupo de dependencia severa domiciliaria; Serie B con doble codificación a resolver en Fase 2 |
| 2026-06-09 | Pregunta rectora fijada: **Q1 Brecha de detección** (con lente territorial); secundarias: Q2 cascada, Q5 equidad étnica/migrante, Q6 multinivel | Numerador P6 verificado + denominador asegurado (INE 65+ × prevalencia 10/66 Chile = 7,0% en 60+, urbano 6,3% / rural 10,3%); absorbe Q3 y enmarca Q5 |
| 2026-06-09 | PND tiene dos capas: GES N°85 universal en APS (cobertura nominal 100%) + dispositivos especializados en ~10 comunas | Separar cero estructural (sin dispositivo) de subregistro (APS que no registra); Q3 implementación pasa a contexto descriptivo, Q4 cuidadores a exploratoria de baja prioridad por subregistro esperado |
| 2026-06-09 | Denominador de equidad = **Censo 2024 (INE)** comunal | Trae pertenencia a pueblos originarios y nacidos en el extranjero por comuna; caveat: eje migrante subpotenciado para demencia (población migrante joven vs demencia 65+) |
| 2026-06-10 | **Fase 1 cerrada** (ver `FASE_1_DATOS.md`): mezcla de celdas caracterizada global (A 67/17/16, BS 73/18/10, BM 95/1/4, P 65/15/20, D 92/1/7 = %NA/%0/%pos; salida canónica `fread`) y por bloque demencia | Diagnóstico base para decidir modelos en Fase 3 |
| 2026-06-10 | El **% NA de celda NO se usará como métrica de subregistro** | Dominado por columnas estructuralmente vacías por diseño del formulario; el subregistro real se mide sobre el panel (filas establecimiento-mes faltantes) en Fase 3 |
| 2026-06-10 | Estructura temporal verificada en el dato: **A/BS mensuales (12 meses), P semestral (jun/dic)** | Confirma panel mensual vs semestral; no forzar plantilla única |
| 2026-06-10 | **Doble codificación Serie B resuelta**: el CSV usa el código col-A `0101xxxx` (`5099xxx` es la alterna del diccionario) | Cierra el pendiente que la Fase 0 dejó a la Fase 2 |
| 2026-06-10 | `P6222300` confirmado numerador limpio (1.224 estab., ambos cortes); `P6223310` (110 estab.) a discriminar antes de sumar | Riesgo de doble conteo de la sección hermana |
| 2026-06-10 | Exceso de ceros + cola larga en bloques de Serie A (mediana 2-15, máx hasta 3.947) | Anticipa hurdle/binomial negativa para A en Fase 3; A06-F con cobertura muy baja (22-143 estab.) confirma subregistro y mantiene Q4 cuidadores como exploratoria |
| 2026-06-10 | **Fase 2 cerrada** (ver `FASE_2_CROSSWALKS.md`): crosswalks de prestaciones y columnas curados y validados | Define universo y significado de columnas; destraba el numerador 65+ y las marginales de equidad |
| 2026-06-10 | **65+ = Col30:Col37** en P6 (APS+Esp.), P3 y A05 (layout etario idéntico, validado: 92-97% del total) | Numerador etario de la rectora; helper `R/utils_columnas.R` lo aplica |
| 2026-06-10 | **`P6222300` (APS) + `P6223310` (Especialidad) se SUMAN, no duplican** | Son niveles de atención distintos del mismo diagnóstico, mismo layout de columnas |
| 2026-06-10 | Marginales PO/migrantes mapeadas con posición distinta por bloque (P6 Col40-43, P3 Col39-42, A05 Col41-42, A26 Col09-10) | El crosswalk de columnas guarda la posición por sección; no asumir posición única |
| 2026-06-10 | **Fase 3 cerrada** (ver `FASE_3_PANEL.md`): panel y cobertura/subregistro por tipo de establecimiento | Separa cero estructural de subregistro |
| 2026-06-10 | **Cruce REM ↔ base maestra DEIS = 100%** con código vigente (`cod_estab`); maestro = Establecimientos vigentes (datos.gob.cl, CC-Zero) | Panel sólido; ningún establecimiento sin atributos |
| 2026-06-10 | **Subregistro temporal solo aplica a Serie P (stock)**; en A/BS de evento se usa cobertura + intensidad | El denominador de 12 meses sobrestima la expectativa en series de evento (ingresos/egresos no ocurren cada mes) |
| 2026-06-10 | **Numerador rector confiable**: P6222300 en CESFAM con 5% de subregistro (80% del volumen); subregistro real concentrado en postas rurales (23%) | El subregistro rural infla la brecha estimada → caveat territorial obligatorio |
| 2026-06-10 | Dispositivos PND visibles en el dato (Centros de Apoyo Comunitario; Unidades de Memoria en hospitales terciarios); rehabilitación cognitiva `28021500` es hospitalaria e intensiva | Insumos del overlay territorial; bloque rehabilitación va en su propia lógica |
| 2026-06-10 | **Fase 4 cerrada** (ver `FASE_4_DENOMINADORES.md`): demencia esperada por comuna desde INE base 2017 (Pob. 2025) + prevalencia 10/66 | Denominador de la brecha; esperada 65+ país = 240.980 (8,4%); cruce comunal REM↔INE = 100% |
| 2026-06-10 | Preview de la rectora: **brecha de detección ≈ 95%** (≈13 mil bajo control SM 65+ vs ≈241 mil esperados) | Magnitud de lo no registrado bajo control SM; se formaliza con corte único + caveats en Fase 5 |
| 2026-06-10 | Numerador = stock de un corte (no jun+dic); **ajuste urbano/rural pendiente** (`comunas_urbano_rural.csv`, Censo 2024) | Evitar doble conteo; activar el eje territorial (rural 10,3% vs urbano 6,3%) |
| 2026-06-10 | Ajuste urbano/rural **activado** (Censo 2017, GeoINE); esperada 65+ = 244.338 | Eje territorial completo desde el inicio del análisis |
| 2026-06-10 | **Fase 5 rectora (Q1) entregada** (ver `FASE_5_ANALISIS.md`): **brecha de detección país = 94,6%** (13.114 bajo control SM 65+ vs 244.338 esperados) | ~1 de cada 20 personas con demencia esperada está bajo control SM público |
| 2026-06-10 | **Gradiente territorial**: detección urbano 7,1% > rural 4,5% > mixto 3,9% | Lo rural es doblemente desfavorable (más prevalencia + más subregistro) |
| 2026-06-10 | **Moran's I = 0,065 (p=0,03)** débil, 0 focos bajo-bajo; **PND visible**: Osorno 24,8% y Punta Arenas 18,9% lideran detección | Brecha generalizada (barrera institucional > geográfica, a confirmar en Q6); el footprint del PND mueve la detección |
| 2026-06-10 | **Denominador refinado con FONASA** (inscritos APS 60+, cobertura pública 85,7%): brecha país pasa a **93,7%** (público) | El REM mide solo la red pública; población INE total contaba isapre (queda como sensibilidad). `tramo_a_pct` añadido como proxy de pobreza |
| 2026-06-10 | Con denominador público, **gradiente se agudiza** (urbano 8,5% vs rural 4,9%) y **Moran's I salta a 0,232** (p≈10⁻¹³) | La distorsión isapre enmascaraba la señal territorial; ahora el territorio sí pesa (a confirmar en Q6) |
| 2026-06-10 | **Q6 multinivel resuelto**: barrera de registro **predominantemente institucional** — establecimiento 53,2% de la varianza (MOR 15,96); comuna 17,6%, región 8,4% (≈26% territorial); Servicio de Salud 13,5% > región | Palanca principal centro a centro; comuna y SS con tracción secundaria. Reconcilia Fase 3 (institucional) y Moran (territorial). Ambos modelos convergieron |
| 2026-06-10 | **Q2 cascada cerrada**: las etapas NO anidan (sospecha 325 ≪ ingreso 15.117 ≈ bajo control 14.514 < domiciliaria 23.209) | Hallazgo limitante: el REM no reconstruye la ruta; sospecha/diagnóstico formal casi sin registrar; detección tardía (domiciliaria > bajo control SM) |
| 2026-06-10 | **Q5 equidad cerrada**: pobreza sin gradiente propio (Spearman −0,003; cuartil más pobre 4,7% ≈ efecto rural); pueblos originarios 2,4% del bajo control (6,7% rural) → posible subdetección | Eje territorial es la inequidad robusta; PO pendiente de denominador Censo 2024; migrante subpotenciado |
| 2026-06-10 | **Fundamentación estadística** redactada y en PDF distribuible (4 partes, por capas para 3 públicos) | `FUNDAMENTACION_ESTADISTICA.md/.pdf`; las 4 preguntas cerradas → listo para Fase 6 dashboard |
| 2026-06-10 | **Fase 6: dashboard Quarto** construido y renderizado OK (Resumen, Cómo leer, Glosario, Territorio con mapa leaflet, 4 preguntas, Robustez) | Lee solo de `productos/`; orden pedagógico; sitio en `docs/`. Pendiente: publicar en GitHub Pages |
| 2026-06-25 | **Auditoría del proyecto** (ver `auditoria.md` y `plan_mejora.md`): núcleo analítico sólido; hallazgos en reproducibilidad, ética de celdas pequeñas, citación y trazabilidad | Modo evaluación con cada skill como rúbrica |
| 2026-06-25 | **A1 verificado:** la prevalencia 10/66 está bien transcrita (Tabla 2 de Fuentes & Albala 2014); el bache 65-69→70-74 es ruido muestral de la fuente, no error | El riesgo real es el denominador de fuente única sin incertidumbre, no la transcripción |
| 2026-06-25 | **Estado del arte** redactado (`estado_del_arte.md`, `busqueda.md`): el indicador del proyecto coincide con el indicador oficial del MINSAL (Mesa Asesora 2024) | Respalda mantener el indicador y robustecer su denominador |
| 2026-06-25 | **Triangulación de prevalencia** añadida (`R/11_sensibilidad_prevalencia.R`): brecha bajo 10/66 raw vs suavizada vs externa (GBD), con intervalo 95% | Reporta la brecha como rango, no como punto |
| 2026-06-25 | **Mejoras de pipeline/ética:** `run_all` falla ruidosamente; stubs `04`/`05` retirados; celdas pequeñas marcadas (`*_pub`); cifras del dashboard leídas de `productos/`; licencias y `CITATION.cff` | Cierre de hallazgos A2, A4, A5, A6, A9 del plan de mejora |

---

## 9. Estado del arte, auditoría y mejora

- `estado_del_arte.md` — qué se sabe del problema (prevalencia y brecha), encuadre epistemológico y vacío preciso; `busqueda.md` — estrategia reproducible.
- `auditoria.md` — evaluación por etapa y transversal con veredictos.
- `plan_mejora.md` — acciones priorizadas por riesgo, con las líneas a correr en Positron.
- `PASOS_POSITRON.md` — runbook para ejecutar las mejoras de esta ronda.

## 10. Licencia y cómo citar

Código bajo **MIT**; datos derivados y documentos bajo **CC BY 4.0**; datos crudos de terceros conservan su licencia de origen (ver `LICENSE`). Para citar el trabajo, ver `CITATION.cff`.

## 11. Declaración de uso de IA

Este proyecto se desarrolló con asistencia de IA (Claude) para programación, análisis y redacción, bajo revisión y decisión humanas. La responsabilidad por el contenido, las cifras y las conclusiones es del autor. La verificación de fuentes (p. ej. la prevalencia 10/66 contra el artículo original) y las decisiones metodológicas fueron validadas por una persona.
