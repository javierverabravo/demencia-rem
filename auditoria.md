# Auditoría del proyecto — Demencia en la red pública (Series REM)

Fecha de la auditoría: 2026-06-25. Modo: **auditar** (evaluar y proponer, sin ejecutar cambios). Estado del proyecto auditado: Fases 0-6 declaradas completas, dashboard renderizado, fundamentación estadística en PDF.

Cada etapa se juzga contra el estándar de su skill del núcleo. Veredictos: **sólido** / **incompleto** / **incorrecto** / **riesgoso**.

---

## Veredicto global

El proyecto es **sólido en su núcleo analítico** y notablemente honesto en sus caveats. La cadena de datos (adquisición, preparación, diagnóstico) y el ajuste de modelos cumplen el estándar de sus skills: NA distinto de cero, panel completo, separación de cero estructural frente a subregistro, convergencia registrada, doble métrica VPC + MOR, corrección del denominador con FONASA, y reconciliación entre el multinivel y el análisis espacial. La comunicación pedagógica por capas es una fortaleza real.

Los problemas no están en las conclusiones sino en **tres frentes**: (1) un probable error de transcripción en la tabla de prevalencia que alimenta el denominador de la pregunta rectora; (2) la infraestructura de reproducibilidad y de publicación abierta, que está por debajo del estándar de sus skills (sin entorno fijado, errores silenciados, sin licencias ni metadatos); y (3) deuda de trazabilidad y entregables a medio terminar (árbol de git sucio, dos archivos del pipeline que son esqueletos, cifras escritas a mano en el dashboard).

Ninguna conclusión publicada parece invalidada. El hallazgo A1 (prevalencia) fue verificado contra la fuente original: las cifras están bien transcritas; el problema es que el denominador descansa en una sola encuesta de 2010 por tamizaje, sin incertidumbre propagada (ver detalle en A1 y en `plan_mejora.md`).

---

## Evaluación por etapa

| Etapa (rúbrica) | Veredicto | Evidencia |
|---|---|---|
| explorar y formular preguntas | sólido | Menú de seis preguntas con anatomía; rectora pospuesta al cierre de Fase 0 y justificada por uso y factibilidad; absorción de Q3 en Q1 documentada. |
| revisar estado del arte | incompleto | No hay revisión de literatura ni encuadre epistemológico explícito. El "estado del arte" se reduce a las fuentes de insumo (10/66, footprint PND). Aceptable para un análisis sectorial, pero la rúbrica lo marca incompleto. |
| adquirir datos | sólido (con reserva) | Procedencia documentada, fecha preliminar declarada (`PARAMS$fecha_datos`), crudo inmutable (gitignored, leído como character), descarga re-ejecutable, maestro DEIS con licencia CC-Zero. Falta un manifiesto con checksum por insumo. |
| preparar datos | sólido | Tidy, tipado explícito, NA distinto de 0, joins verificados (REM ↔ maestro 100%, REM ↔ INE 100%), crosswalks curados y validados (total = H+M; total ≈ Σ bandas). |
| diagnosticar datos | sólido | Caracterización de celdas por serie y bloque; exceso de ceros y cola larga identificados; estructura temporal verificada (A/BS mensual, P semestral); decisión de modelos registrada en bitácora. |
| investigar método | sólido | Método justificado y pre-anunciado; objetivo descriptivo bien delimitado; se declara explícitamente que el REM no permite causalidad ni trayectorias individuales. |
| ajustar modelo | sólido (con reserva A1) | Convergencia verificada y registrada en `modelo_estado.csv`; VPC acompañado de MOR (robusto a la convención π²/3); sensibilidad de denominador (INE total vs FONASA). Reservas: solo modelo vacío (correcto para partición de varianza); **sin sensibilidad sobre la prevalencia** (denominador de fuente única, ver A1), por lo que la brecha se reporta como punto y no como intervalo. |
| construir pipeline reproducible | incompleto / riesgoso | Sin `renv` (entorno no fijado: `install.packages` bajo demanda); sin `targets` (orquestación por for-loop). `10_run_all.R` envuelve cada script en `tryCatch` que **traga el error y continúa**: una corrida puede saltarse pasos rotos y reportar "completado". Contraviene el principio de fallar ruidosamente. |
| comunicar resultados | sólido / incompleto | Dashboard pedagógico por capas, glosario, caveats visibles, mapa leaflet. Pero cifras headline escritas a mano en `deteccion.qmd` (A6) e informe técnico `articulo.qmd` sin terminar (A7). |
| construir app Shiny | n/a | No se construyó, y se justificaba no hacerlo: el dashboard estático cubre la necesidad. Correcto. |
| publicar abierto | incompleto | Dashboard en GitHub Pages, pero sin licencias por capa, sin `CITATION.cff`, sin DOI ni metadatos FAIR. Declarado como pendiente de Fase 6. |

---

## Evaluación de transversales

**Rigor.** Sólido en general: bitácora de decisiones extensa, caveats sistemáticos, reporte de resultados nulos y limitantes (la cascada que no anida se declara como hallazgo, no se esconde), análisis confirmatorio anunciado de antemano. Pendiente: separación formal explícita entre confirmatorio y exploratorio, y la verificación del hallazgo A1.

**Ética y gobernanza.** Riesgo medio. Los datos REM son agregados administrativos públicos del DEIS (base de licitud razonable, aunque no declarada explícitamente). El punto a mirar es la **divulgación por celdas pequeñas** (A2): `productos/brecha_comuna.csv` y el mapa publican comunas con denominador de ~20-38 personas 65+ y numerador de 0-1 persona bajo control; la composición de pueblos originarios/migrantes opera sobre conteos minúsculos por zona. Aunque el origen ya es público, la combinación de tasa comunal + composición de equidad merece una regla de supresión o redondeo de celdas pequeñas, o al menos una nota.

**Citación.** Riesgo medio. Las referencias (10/66, INE base 2017, FONASA, Merlo et al. 2006, Goldstein et al. 2002, Mood 2010, Snijders & Bosker 2012) se nombran pero **sin identificadores verificables** (DOI/URL) ni precisión de tabla/página para la prevalencia. No hay `CITATION.cff` para citar el propio trabajo. La skill `citar-fuentes` exige atribución verificable con identificador persistente.

**Estilo de entregables.** La fundamentación se dirige al lector ("lee", "te dice") y usa secciones "En simple". Es una decisión consciente de comunicación multi-audiencia, defendible, pero choca con el registro impersonal de `estilo-entregables`. No es un defecto si se asume como producto de divulgación; conviene declararlo.

**Declaración de uso de IA.** Ausente. Ningún entregable declara la asistencia de IA en su elaboración. La persona es responsable del contenido, pero la declaración corresponde.

---

## Hallazgos (resumen; el detalle priorizado y las acciones van en `plan_mejora.md`)

1. **A1 · Denominador de prevalencia de fuente única, con ruido por banda (rigor, alto).** El denominador de la rectora descansa en **un solo estudio**: Fuentes & Albala (2014, Dement Neuropsychol 8(4):317-322), que a su vez reporta una **única encuesta** (Estudio Nacional de la Dependencia, SENAMA 2010; n=4.860; demencia por tamizaje MMSE<22 + Pfeffer>5). Verificado contra la Tabla 2 del artículo: los valores del código **coinciden exactamente** con la fuente, de modo que la no-monotonía 65-69 (4,1%) → 70-74 (3,7%) **no es error de transcripción**, sino ruido muestral de la propia encuesta (el paper afirma que la prevalencia sí crece con la edad, p<0,0001). El riesgo real es triple: (a) fuente única y antigua (2010, pre-Censo 2024); (b) definición por tamizaje sensible a baja escolaridad, que confunde el alza rural con educación (el OR rural ajustado del paper baja de ~1,8 a ~1,4); (c) prevalencias puntuales sin incertidumbre propagada, de modo que la brecha se reporta como 93,7% seco. Afecta el denominador de la pregunta rectora y el eje territorial.
2. **A2 · Celdas pequeñas publicadas (ética, medio).** Tasas comunales y composición de equidad sobre numeradores de 0-1 y poblaciones de ~20-40; riesgo de divulgación pese al origen público.
3. **A3 · Bibliografía sin identificadores verificables y sin CITATION.cff (citación, medio).**
4. **A4 · Reproducibilidad: sin `renv`, sin `targets`, errores silenciados en `run_all` (reproducibilidad, medio-alto).**
5. **A5 · `04_engine.R` y `05_indicadores.R` son esqueletos (`stop("pendiente")`) pero figuran en el pipeline y en la arquitectura documentada del README (coherencia, medio).** El motor común que el README declara no existe; 06-09 reimplementan la lógica directamente.
6. **A6 · Cifras headline a mano en `deteccion.qmd` (trazabilidad, medio).** 93,7 %, 94,6 %, 13.114, 205.843 escritas en el texto/tabla, no leídas de `productos/`.
7. **A7 · `articulo.qmd` (informe técnico PDF) incompleto (entregable, medio).** Esqueleto con TODOs; el rol lo cumple `FUNDAMENTACION_ESTADISTICA`, pero el README promete ambos.
8. **A8 · Árbol de git sucio, bitácora fuera de la historia (trazabilidad, medio).** Casi todos los archivos modificados sin commit; solo dos commits. La bitácora vive en el README, no en la historia versionada.
9. **A9 · Sin licencias por capa ni DOI (publicación, bajo).** Pendiente declarado de Fase 6.
10. **A10 · Estado del arte y encuadre epistemológico ausentes (rigor/contexto, bajo).**
11. **A11 · Sin declaración de uso de IA (transversal, bajo-medio).**

---

## Lo que está bien y no debe tocarse

Conviene preservarlo al intervenir: la lectura de crudos como character (NA ≠ 0), la degradación elegante ante insumos faltantes, el panel completo con separación de cero estructural y subregistro, el registro de convergencia en `modelo_estado.csv`, la doble métrica VPC + MOR, la corrección del denominador con FONASA y su sensibilidad, la reconciliación entre multinivel y Moran, el tratamiento honesto de la cascada como resultado limitante, los crosswalks versionados y validados, y la arquitectura de comunicación por capas para tres públicos.
