# Fase 0 · Instrumento — verificación y elección de pregunta rectora

> Entregable de la Fase 0 (junio 2026). Verifica la tabla §2 del README contra los diccionarios de códigos REM 2025 (`Diccionarios/`) y los manuales REM 2025-2026, mapea las columnas de equidad (pueblos originarios / migrantes), fija las fuentes externas (prevalencia por edad, footprint del Plan Nacional de Demencia, denominador de equidad) y, con eso, evalúa la factibilidad de las 6 preguntas y fija la pregunta rectora. **No avanzar a Fase 2 sin esta tabla.**
>
> Método: lectura programática de los `.xlsm` (una hoja por formulario; la columna A es el código de celda, las filas-encabezado definen el significado de cada `Col`; las fórmulas `=IF(...)` del diccionario **son** las reglas de consistencia). Cada código de la tabla §2 fue localizado y leído en su hoja.

---

## 1. Tabla §2 verificada (REM 2025)

Estado: **✓ confirmado** (existe, etiqueta y ubicación coinciden) · **⚠ matiz** (existe pero el README necesita corrección/precisión) · **✗ no corresponde**.

| Serie/Form. | Sección (diccionario 2025) | Código(s) verificados | Qué mide realmente | Estado |
|---|---|---|---|---|
| **A03** (EMPAM y escalas) | Secc. D.6 *Escala Zarit abreviado en cuidadores* | `03500361` (con sobrecarga intensa), `03500362` (sin sobrecarga intensa) | Cuidador/a de paciente con **dependencia severa** evaluado con Zarit. No es específico de demencia: capta sobrecarga del cuidador de dependencia severa (que **incluye** demencia, sin poder aislarla). | ⚠ |
| **A03** | Aplicación de escalas | `09600226` *Nº de escala de depresión geriátrica Yesavage GDS-15* | Cribado de **depresión** geriátrica, no de demencia. Relevancia indirecta (comorbilidad / EMPAM). | ⚠ |
| **A05** (ingresos/egresos SM) | Secc. N *Ingresos al programa de salud mental APS/Especialidad* | `05901801` (ingreso, Demencias incl. Alzheimer, **Leve**; hay filas hermanas Moderada/Severa), `05224201` (egreso, mismo eje) | Ingresos y egresos del programa de salud mental por diagnóstico **"Demencias (Incluye Alzheimer)"**, desagregado por severidad. Columnas = grupos etarios (0-4 … **65-69, 70-74, 75-79, 80 y más**) × sexo **+ Pueblos Originarios + Migrantes**. → 65+ aislable y con equidad. | ✓ |
| **A05** | Secc. K/L *Clasificación funcional adulto mayor* | `05021207`, `05050700` (EMPAM "Autovalente sin riesgo") | **Corrección al README**: estos dos códigos son **EMPAM / funcionalidad del adulto mayor**, no demencia. El README los listó bajo demencia. Útiles como contexto de funcionalidad, no como conteo de demencia. | ⚠ (recolocar) |
| **A06** (Programa SM) | Secc. A.1 *Controles SM APS/Especialidades* | bloque `06020201`… (controles por profesional) | Controles SM con **columnas marginales**: Pueblos Originarios, Migrantes, **Demencia**, Trans, **Cuidadores de personas con demencia**. La marginal "Demencia" marca cuántos controles fueron a personas con demencia. | ✓ |
| **A06** | Secc. A.2 *Consultorías y teleconsultorías SM* | `06300100`, `06907017` | Columnas marginales: Pueblos Originarios, Migrantes, **Personas con sospecha de demencia**, **Personas con diagnóstico de demencia**. → insumo de la etapa "sospecha" de la cascada. | ✓ |
| **A06** | **Secc. F** *Evaluaciones Programa Plan Nacional de Demencia* | `06906135` (reevaluación deterioro global **GDS Reisberg**), `06906140` (cuidador: reevaluación **sobrecarga**), `06906145` (cuidador: **satisfacción usuaria**) | Núcleo del PND en el REM: evaluaciones específicas de la persona con demencia y su cuidador. Pocas columnas (Col01-09) → desagregación menor; esperar **alto subregistro** (sección nueva). | ✓ |
| **A19a** (familias) | Familias | `19201021` *Con integrante con demencia* | Familias con un integrante con demencia (Col01-02). Conteo grueso, sin edad/sexo. | ✓ |
| **A26** (atención domiciliaria PADDS) | Secc. A.1 *Visitas domiciliarias a dependencia severa* | `26411011` (familia con dependencia severa en etapa terminal, **excluye** estadios avanzados de demencia), `26411012` (dependencia severa **sin** diagnóstico de demencia) | El eje distingue dependencia severa **con vs sin** demencia, pero por la vía de la **familia/PADDS**, no un conteo directo de personas con demencia. `26411010` es el total del eje. Útil para domiciliaria, leer con cuidado. | ⚠ |
| **A27** (prevención/promoción) | Áreas temáticas de prevención | `29101573`, `29101581` *Escala Yesavage GDS-15* | **Depresión** geriátrica otra vez, no demencia. Tiene columnas Pueblos Originarios/Migrantes, pero la relevancia para demencia es marginal. **Candidata a descartar** del universo demencia. | ✗/⚠ |
| **A28** (rehabilitación) | Diagnóstico / actividades | `28201001` *Alzheimer y otras demencias* (eje diagnóstico); `28022300`/`28021500` *Estimulación cognitiva*; `28020840`/`28020900` *Cuidadores* | Rehabilitación con eje diagnóstico "Alzheimer y otras demencias" y prestaciones de estimulación cognitiva. Relevante para el bloque rehabilitación/BS. | ✓ |
| **A32** (SM comunitaria/digital) | Videollamadas / actividades | rango `321006xx`–`321008xx` | Columnas marginales Pueblos Originarios, Migrantes y **Demencia**. Canal digital/comunitario; volumen probablemente bajo. | ✓ |
| **BS · B** (prestaciones trazadoras) | Prestaciones | `01010053` *Evaluación cognitiva*, `01010054` *Estimulación cognitiva*, `01010916` *Evaluación de funciones cognitivas* (+ rango `01010916-38`) | Prestaciones cognitivas. **Trampa de crosswalk confirmada**: la col. A es `01010053` pero la col. B trae otro código (`5099063`, `5099064`, `0102505`). **Verificar en Fase 2 cuál aparece como `CodigoPrestacion` en el CSV.** | ✓ (con alerta) |
| **P · P3** (pob. bajo control adulto mayor) | Atención domiciliaria por dependencia severa | `P3171613` *Con Demencia* | **Matiz**: no es un registro autónomo "adulto mayor con demencia", sino el subgrupo **Con Demencia dentro de dependencia severa en atención domiciliaria**. Stock semestral, columnas etarias × sexo. | ⚠ |
| **P · P6** (pob. bajo control SM) | Diagnósticos SM | `P6222300` (Leve), `P6223310` (otra severidad) *Demencias (incluye Alzheimer)* | **El conteo más limpio de población bajo control por demencia.** Stock semestral (junio/diciembre), por severidad, columnas etarias × sexo, bajo encabezado de sección que incluye Pueblos Originarios/Migrantes. → numerador principal de la brecha de detección. | ✓ |
| **D · D16** | PACAM | — (sin código de demencia) | Programa alimentario del adulto mayor. **Contextual**, no mide demencia. | ⚠ (contexto) |

**Conclusión de la verificación:** todos los códigos del README existen en el diccionario 2025. Correcciones a incorporar: (a) en A05, `05021207`/`05050700` son EMPAM, no demencia; los códigos de demencia son `05901801`/`05224201` con severidad; (b) A27 (`291015xx`) es Yesavage/depresión → fuera del universo demencia salvo como comorbilidad; (c) P3 "Con Demencia" es subgrupo de dependencia severa domiciliaria, no un registro autónomo; (d) en Serie B verificar la doble codificación antes del crosswalk.

---

## 2. Mapa de columnas de equidad (pueblos originarios / migrantes)

Las columnas de equidad son **marginales independientes** (no se cruzan entre sí ni con edad/sexo). Dónde aparecen, atadas a las secciones con contenido de demencia:

| Serie/Sección | Pueblos Originarios | Migrantes | Atadas a fila de demencia | 65+ aislable |
|---|---|---|---|---|
| A05 Secc. N (ingresos SM, demencia) | ✓ | ✓ | Sí (mismo bloque etario × sexo del diagnóstico) | Sí |
| A06 Secc. A.1 (controles SM) | ✓ | ✓ | Marginal de la sección + marginal "Demencia" | Por grupo etario de la sección |
| A06 Secc. A.2 (consultorías) | ✓ | ✓ | Sí (+ sospecha/diagnóstico demencia) | Por grupo etario |
| P6 (pob. bajo control SM, demencia) | ✓ | ✓ | Sección que contiene la fila demencia | Sí (stock semestral) |
| P3 (dependencia severa domiciliaria) | ✓ | ✓ | Sección; **pinear COL exactas en Fase 2** | Sí |
| A03 (EMPAM/escalas) | ✓ | ✓ | En la sección, no específica de demencia | Parcial |
| A27, A31, A32 | ✓ | ✓ | A32 con marginal "Demencia" | Variable |

**Pendiente de Fase 2:** fijar el índice exacto `Col` de las marginales Pueblos Originarios / Migrantes dentro de cada sección de demencia (la presencia está confirmada; la posición de columna se cura en el crosswalk de columnas).

---

## 3. Fuentes externas fijadas

### 3.1 Prevalencia de demencia por edad (Chile) — para la brecha de detección
Estudio **10/66 en Chile** (muestras urbana y rural), reportado en *"An update on aging and dementia in Chile"* (Dement Neuropsychol; PMC5619178). Prevalencia (%) de demencia:

| Grupo | 60-64 | 65-69 | 70-74 | 75-79 | 80-84 | ≥85 |
|---|---|---|---|---|---|---|
| Urbano | 0,94 | 3,9 | 3,0 | 8,4 | 17,2 | 29,0 |
| Rural | 2,6 | 5,1 | 6,9 | 10,6 | 29,7 | 50,4 |
| **Total** | **1,2** | **4,1** | **3,7** | **8,8** | **19,4** | **32,6** |

Prevalencia global 60+ = **7,0%** (mujeres 7,7%; hombres 5,9%); **rural 10,3% vs urbano 6,3%**. La diferencia urbano/rural es el ancla del eje territorial: el mismo denominador etario rinde una prevalencia esperada mayor en comunas rurales. (El propio Plan Nacional usa esta familia de cifras; ENADEM da 60-64 ≈ 1,2% y 65-69 ≈ 4,1%, coherente.)

### 3.2 Footprint del Plan Nacional de Demencia (PND) — para delimitar el universo del programa
Dos capas con lógicas distintas (clave para separar cero estructural de subregistro):

- **Capa universal (APS): GES N°85 "Alzheimer y otras demencias"** (Decreto GES N°22, oct-2019; Orientaciones Técnicas MINSAL 2023). Garantía de sospecha → confirmación → tratamiento con **cobertura nominal del 100%** de beneficiarios GES en todo el país. → la *detección* en APS debería existir en toda comuna; la variación es de **registro/actividad**, no de presencia del programa.
- **Capa especializada (concentrada):** **7 Centros de Apoyo Comunitario para personas con demencia** en funcionamiento (Peñalolén, El Bosque, Rancagua, Los Andes/San Felipe, Hualpén, Osorno, Punta Arenas), con Coquimbo, Talca y Temuco en apertura; más **Unidades de Memoria** en hospitales de mediana/alta complejidad. → presencia en ~10 comunas: cero estructural fuera de ellas.
- Marco vigente actualizado: **Plan Nacional de Demencia 2025-2035** (MINSAL/DIPRECE, marzo 2026).

Implicación: la "equidad de implementación" (pregunta 3) se parte en dos: a nivel APS es casi universal (se mide como brecha de **registro/detección**, que cae dentro de la rectora); a nivel especializado es un set chico de comunas, analizable de forma **descriptiva**, no inferencial.

### 3.3 Denominador de equidad (pueblos originarios / migrantes por comuna)
**Censo 2024 (INE)** — incluye pertenencia a pueblos originarios y población nacida fuera del país, disponible a nivel **comunal** (portal censo2024.ine.gob.cl). Migrantes = 1.608.650 (8,8% del país), concentrados en el norte (Tarapacá 23,2%, Antofagasta 19,7%, Arica 14,9%). Población originaria con peso alto en Araucanía/Los Lagos/norte andino. Es la fuente del denominador comunal de equidad.

**Caveat de potencia:** la migración chilena es predominantemente joven (edad activa); como la demencia se concentra en 65+, los conteos de demencia en migrantes serán muy bajos → el eje **migrante** probablemente quede **subpotenciado** para demencia. El eje **pueblos originarios** es más viable (poblaciones mayores y rurales).

---

## 4. Factibilidad de las 6 preguntas (§1)

| # | Pregunta | Numerador/insumo REM | Denominador/externo | Factibilidad |
|---|---|---|---|---|
| 1 | **Brecha de detección** | P6 demencia (stock semestral) ✓; apoyo P3 | INE 65+ comunal × prevalencia 7%/banda ✓ | **Alta.** Insumos verificados; naturalmente territorial (urbano/rural + LISA). |
| 2 | **Cascada de atención** | A06 sospecha/diagnóstico → A05 ingreso → P6 bajo control → A26/P3 domiciliaria ✓ | — | **Media-alta.** Todas las piezas existen, pero mezcla atenciones mensuales con stock semestral → embudo **agregado** (sin seguir individuos), con caveats fuertes. |
| 3 | **Equidad de implementación PND** | A06 secc. F; presencia de dispositivos | Footprint PND (§3.2) | **Media.** APS casi universal → se confunde con detección (cae en Q1); capa especializada = ~10 comunas → solo **descriptivo**. |
| 4 | **Cuidadores** | A03 D.6 (Zarit) + A06 secc. F (`06906140/45`) ✓ | — | **Media-baja.** Existe, pero el Zarit no aísla demencia y la secc. F es nueva → **alto subregistro** esperado. Exploratoria. |
| 5 | **Equidad étnica/migrante** | Marginales Pueblos Originarios/Migrantes en A05, A06, P3, P6 ✓ | Censo 2024 comunal ✓ | **Media.** Pueblos originarios viable; **migrantes subpotenciado** (demencia es 65+). Análisis marginal por sección, sin cruces. |
| 6 | **¿Dónde vive la variación?** | Panel establecimiento ⊂ comuna ⊂ región | — | **Alta técnicamente**, pero secundaria de propósito (es el motor multinivel, no una pregunta de política en sí). |

---

## 5. Decisión: pregunta rectora + secundarias

Elección fundada en la factibilidad de los datos (decidida en esta fase, como pide el README §1).

**Pregunta rectora — Q1, Brecha de detección de demencia (con lente territorial).**
> En cada comuna, ¿cuánta de la demencia *esperada* en la población de 65+ (prevalencia por banda etaria × proyección INE, ajustada urbano/rural) está efectivamente **bajo control** en la red pública (P6), y dónde están las mayores brechas?

Por qué rectora: (a) máxima relevancia de política (dimensiona lo que el sistema *no* ve y lo localiza); (b) insumos completamente verificados — numerador limpio (P6, stock semestral por severidad y edad) y denominador asegurado (INE 65+ × prevalencia 10/66); (c) es intrínsecamente territorial (el diferencial urbano/rural de prevalencia + Moran/LISA sobre la brecha comunal); (d) **absorbe** la pregunta 3 (la inequidad de implementación a nivel APS se manifiesta como brecha de detección) y da el marco para la 5 (la brecha étnica se lee *sobre* la brecha de detección).

**Secundarias (3):**
1. **Cascada de atención (Q2)** — embudo agregado sospecha (A06) → ingreso (A05) → bajo control (P6) → domiciliaria (A26/P3): ¿en qué eslabón y en qué territorios se pierde la gente? Con caveat explícito de que son tasas agregadas, no trayectorias individuales.
2. **Equidad étnica y migrante (Q5)** — análisis marginal de % pueblos originarios (y, con caveat de potencia, % migrantes) en detección y bajo control, contra el peso poblacional comunal (Censo 2024). Lectura territorial: ¿dónde la brecha étnica es mayor? Sin cruces entre columnas marginales.
3. **¿Dónde vive la variación? (Q6)** — multinivel (establecimiento ⊂ comuna ⊂ región, ICC + MOR; Servicio de Salud como nivel alternativo) sobre la **barrera de registro**, como columna vertebral metodológica que sostiene la interpretación de la brecha.

**Relegadas:** Q4 cuidadores → exploratoria de baja prioridad (subregistro esperado en A06 secc. F; Zarit no aísla demencia). Q3 implementación → se integra como **contexto territorial descriptivo** (overlay del footprint PND), no como bloque inferencial propio.

**Lo que el REM no podrá responder (declarar siempre):** prevalencia real (solo ve a quien contacta el sistema), nada individual, sin progresión/mortalidad, sin causalidad. Las desagregaciones (sexo, edad, pueblos originarios, migrantes) son marginales independientes: no se cruzan entre sí.

---

## 6. Pendientes que esta fase deja amarrados para Fase 1-2

- Serie B: resolver la **doble codificación** (`01010053` vs `5099063`) — verificar cuál es el `CodigoPrestacion` del CSV antes del crosswalk.
- Fijar el índice `Col` exacto de las marginales Pueblos Originarios/Migrantes y de los grupos etarios 65+ en P6, P3, A05, A06 (crosswalk de columnas, Fase 2).
- Descargar proyecciones INE 65+/60+ comunales y la tabla de prevalencia por banda (ya citada) a `datos/externos/`.
- Bajar el listado oficial de dispositivos PND (Centros de Apoyo Comunitario + Unidades de Memoria) para el overlay territorial.
