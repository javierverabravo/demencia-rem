# Fundamentación estadística — explicada para todo público

> Este documento explica, paso a paso y sin dar nada por sabido, **cómo se obtuvieron las cifras del análisis y por qué significan lo que decimos que significan**. Está escrito en capas para que sirva a tres lectores distintos:
>
> - **Sociedad civil / personas interesadas**: lee las secciones **"En simple"** de cada parte. No necesitas matemáticas.
> - **Tomadores de decisiones**: lee "En simple" + **"Qué implica para la política"**. Te dice qué hacer y con qué confianza.
> - **Academia / equipos técnicos**: lee todo, incluido el detalle de fórmulas, supuestos, citas y caveats.
>
> El análisis responde dos preguntas encadenadas: **(1) ¿cuánta demencia de las personas mayores está bajo control en la red pública, y dónde está la mayor brecha?** y **(2) ¿de qué depende que un centro registre o no la demencia: del centro, de la comuna o de la región?** Cada una es una Parte de este documento. Todas las cifras son reproducibles corriendo el código del proyecto (`R/06_analisis_deteccion.R` y `R/09_sintesis.R`).

---

# Parte 1 · La brecha de detección de demencia

## 1.1 La pregunta y por qué importa

**En simple.** La demencia tiene una frecuencia conocida en la población mayor: a más edad, más casos. Con eso se puede **estimar cuántas personas mayores con demencia hay** en cada comuna. La pregunta es: de todas esas personas esperadas, **¿cuántas están efectivamente bajo control en la red pública de salud mental?** La diferencia entre lo esperado y lo registrado es la **brecha de detección**.

**Qué implica para la política.** La brecha dimensiona **lo que el sistema no está viendo**, y lo localiza comuna por comuna. Es la base para decidir dónde reforzar la detección, a quién priorizar y cómo medir avances en el tiempo.

---

## 1.2 Cómo se construye la cifra: numerador y denominador

**En simple.** La brecha es una resta sencilla, en proporción:

```
Brecha = 1 − ( personas bajo control / personas esperadas )
```

- **Numerador (bajo control):** personas de **65 años o más** que están **bajo control por demencia en salud mental** en la red pública, según el registro estadístico (REM). Es una "foto" del stock a diciembre de 2025: **13.114** personas en todo el país.
- **Denominador (esperadas):** cuántas personas de 65+ con demencia se **esperan** en cada comuna, según su población y la frecuencia de demencia por edad.

**Detalle técnico.**

- El numerador suma dos registros del mismo diagnóstico "Demencias (incluye Alzheimer)": el de **atención primaria** (código `P6222300`) y el de **especialidad** (`P6223310`). Se verificó que **no se duplican** (son niveles de atención distintos) y que comparten el mismo formato de columnas (Fase 2).
- Se usa **un solo corte** (diciembre), no la suma de los dos cortes semestrales (junio + diciembre), porque el denominador es una **prevalencia** (un stock, no un flujo): sumar los dos cortes contaría a la misma persona dos veces.
- El denominador se arma con las **proyecciones de población del INE** (2025, por comuna y edad) multiplicadas por la **prevalencia de demencia por tramo de edad** del estudio **10/66 en Chile** (de 4 % a los 65-69 años hasta 33 % sobre los 85). La estructura de edad hace casi todo el trabajo: las comunas más envejecidas concentran más casos esperados.

---

## 1.3 El denominador correcto: por qué FONASA cambia (y mejora) el número

**En simple.** Aquí hay una sutileza que importa mucho. El registro REM **solo mide la red pública de salud**. Pero no toda la población usa la red pública: cerca del 15 % de los adultos mayores está en **isapres** (seguros privados), concentrados en comunas urbanas de altos ingresos. Si comparamos lo que registra el sistema **público** contra **toda** la población (incluida la de isapre que nunca pisa un consultorio público), estamos exigiéndole al sistema público que "vea" a personas que no le corresponden. Eso **infla artificialmente la brecha**.

La solución: usar como denominador la población realmente **inscrita en FONASA / atención primaria pública** (el universo que el sistema público sí debe atender). En Chile, FONASA cubre el **85,7 %** de los adultos mayores.

| | Denominador = población total (INE) | Denominador = población pública (FONASA) |
|---|---:|---:|
| Personas 65+ esperadas con demencia | 244.338 | **205.843** |
| Bajo control (numerador) | 13.114 | 13.114 |
| Tasa de detección | 5,4 % | **6,3 %** |
| **Brecha de detección** | 94,6 % | **93,7 %** |

**Qué implica.** La cifra honesta es **93,7 %** (no 94,6 %): contar a la población de isapre exageraba un poco la brecha. Y, sobre todo, hizo la comparación entre territorios **justa** (las comunas rurales son casi 100 % FONASA; las urbanas no). Como efecto secundario valioso, **limpiar el denominador destapó la señal territorial** que antes estaba enmascarada (ver §1.5).

---

## 1.4 El resultado, y qué NO dice

**En simple.** La red pública de salud mental tiene bajo control a **alrededor de 1 de cada 16** personas mayores con la demencia que se espera en la población. La brecha es del **93,7 %**.

**Qué significa y qué no.** Es crucial leerlo bien:

- **No** significa que el 94 % de las personas con demencia esté abandonado. Mucha demencia se maneja en atención primaria sin quedar registrada "bajo control de salud mental", en el sector privado, o en la familia.
- **Sí** significa que el **subsistema de salud mental pública** tiene visibilidad y seguimiento formal sobre una fracción pequeña de la demencia esperada. Es una medida de **cuánto ve y sigue el sistema**, que es justamente lo que se necesita para planificar.

---

## 1.5 El gradiente territorial (el corazón del hallazgo)

**En simple.** Separando las comunas según cuán rurales son:

| Tipo de comuna | Tasa de detección | Brecha |
|---|---:|---:|
| Urbana | **8,5 %** | 91,5 % |
| Rural | 4,9 % | 95,1 % |
| Mixta | 4,4 % | 95,6 % |

Las comunas **urbanas detectan casi el doble** que las rurales. Y lo rural carga una **doble desventaja**: allí la demencia esperada es **mayor** (la frecuencia es más alta en zonas rurales: 10,3 % vs 6,3 %) **y** el registro es **menor** (en la Fase 3 vimos que las postas rurales dejan de registrar el 23 % de los períodos esperados, contra 5 % de los CESFAM). La demencia rural es la más invisible para el sistema.

**Qué implica para la política.** El refuerzo de la detección debe **priorizar lo rural**, no por equidad abstracta sino porque ahí coinciden más necesidad y menos registro.

---

## 1.6 Los focos en el mapa (Moran y LISA)

**En simple.** ¿La detección se **agrupa** geográficamente —comunas con buena detección rodeadas de otras buenas, y viceversa— o está repartida al azar? Para eso existe el **índice de Moran**: mide cuánto se parecen las comunas vecinas. Va de 0 (al azar) a 1 (muy agrupado).

- Con el denominador de población total, el Moran era débil (0,065).
- Con el denominador correcto (FONASA), **saltó a 0,232** (altamente significativo). La distorsión de las isapres estaba **escondiendo** la estructura territorial. La detección **sí** se agrupa geográficamente.

El análisis **LISA** localiza los grupos: aparece un **clúster de buena detección en el sur austral** (Los Lagos, Aysén). Y, de forma muy reveladora, las comunas que **lideran** la detección son **Osorno (27 %)** y **Punta Arenas (22 %)** — ambas sedes de **Centros de Apoyo Comunitario para personas con demencia** del Plan Nacional de Demencia. **Donde está el programa especializado, la detección sube notablemente.**

**Qué implica.** Es un argumento empírico directo para **extender el footprint del Plan Nacional**: los lugares que lo tienen muestran, en los datos, mejor detección.

**Detalle técnico.** Contigüidad tipo *queen*, pesos estandarizados por fila, `zero.policy` para comunas insulares. Es un análisis **ecológico** (comunas, no personas) y sujeto al **MAUP** (los resultados dependen de la unidad territorial elegida). La prueba formal de "¿registro institucional o geografía?" no es el Moran sino el modelo multinivel (Parte 2).

---

## 1.7 Qué implica para cada lector

**Para la sociedad civil.** La inmensa mayoría de la demencia esperada en personas mayores no está bajo seguimiento de la salud mental pública, y la situación es peor en el campo, donde hay más casos y menos registro. Pero hay una buena noticia accionable: donde existe el programa especializado (como en Osorno o Punta Arenas), las cosas mejoran de forma visible.

**Para tomadores de decisiones.** La brecha del 93,7 % marca un punto de partida medible. Las dos palancas que los datos respaldan: **(a) priorizar lo rural** (más necesidad + más subregistro) y **(b) extender los dispositivos del Plan Nacional**, que se asocian a mayor detección. La cifra se puede recalcular cada año con el mismo código para monitorear avances.

**Para la academia.** Brecha = 1 − (numerador stock P6 65+, corte único / denominador esperado). Denominador primario: población FONASA × prevalencia 10/66 ajustada urbano/rural; población total como sensibilidad. Análisis espacial: Moran global + LISA, ecológico, con caveat MAUP. Limitaciones detalladas en §1.8.

---

## 1.8 Caveats de la Parte 1 (declarar siempre)

- El numerador es **bajo control de salud mental** (`P6`), no toda la atención de demencia: la brecha mide visibilidad del subsistema SM, no demencia sin ningún contacto.
- El **subregistro rural** infla la brecha rural: parte del gradiente es falta de registro, no falta de detección real (ambas cosas, de todos modos, son problemas).
- Prevalencia 10/66 y proyecciones INE **base 2017** (previas al Censo 2024); cobertura pública FONASA en tramos de 10 años (escalada vía 60+). El denominador tiene incertidumbre.
- Análisis **ecológico** y **MAUP**: las tasas comunales no se interpretan a nivel de personas. En comunas muy pequeñas el denominador es chico y la tasa puede ser inestable.

---

# Parte 2 · ¿Dónde vive la variación en el registro? (multinivel)

## 2.1 La pregunta y por qué importa

**En simple.** La Parte 1 mostró *cuánta* demencia no se registra y *dónde*. La Parte 2 pregunta *de qué depende* que un centro registre o no: **¿del centro concreto** (su gestión, su equipo, sus prácticas), **de la comuna, o de la región?**

**Qué implica para la política.** Cambia *dónde poner el esfuerzo*: si la variación vive en el **establecimiento**, la intervención es **centro a centro**; si vive en el **territorio**, es comunal o regional. Una política dirigida al nivel equivocado gasta sin mover el problema.

---

## 2.2 Qué datos usamos y qué medimos

**En simple.** Tomamos **todos los centros de atención primaria activos** (2.027) y miramos **mes a mes** una pregunta de sí/no: *¿este centro registró actividad de demencia este mes?* Son **24.324** observaciones "centro-mes". En el **39,9 %** hubo registro. Ese promedio esconde una variación enorme, y esa variación es la que repartimos entre niveles.

**Decisiones de diseño (técnico).** (1) El desenlace es la **barrera de registro** (binaria), donde se juega la visibilidad. (2) Solo **APS activos**, para separar el "no corresponde" (cero estructural) del "corresponde y no se hizo" (subregistro). (3) Solo **códigos específicos de demencia**.

---

## 2.3 Por qué un modelo "multinivel" y no un promedio

**En simple.** Los datos están anidados como **muñecas rusas**: cada mes dentro de un centro, cada centro dentro de una comuna, cada comuna dentro de una región. Un promedio regional simple no sabe distinguir si una diferencia entre regiones viene de las regiones o de que tienen centros distintos adentro. El **modelo multinivel** hace las tres preguntas a la vez y reparte la variación limpiamente entre niveles.

**Especificación (técnico).** Modelo logístico de **interceptos aleatorios de tres niveles**, sin covariables (modelo "vacío", el correcto para una partición de varianza):

```
logit( P(registra) ) = β₀ + u_región + u_comuna + u_establecimiento
```

Estimado con **glmmTMB** (aproximación de Laplace).

---

## 2.4 Cómo se leen las dos cifras clave (VPC y MOR)

Damos dos números por nivel, **a propósito**: uno intuitivo que depende de una convención, y otro robusto que no. Si coinciden, la conclusión es sólida.

### VPC — "qué porcentaje de la variación vive en este nivel"

**En simple.** Reparte el 100 % de la variación entre los niveles. Establecimiento 53 % = más de la mitad de por qué unos centro-mes registran y otros no se explica por diferencias **persistentes entre centros**.

**Cálculo (técnico).** En un modelo logístico, la variación de más abajo (mes a mes dentro del centro) se fija por convención en **π²/3 ≈ 3,29** (la varianza de la logística estándar; Goldstein et al. 2002). El VPC de cada nivel es su varianza sobre el total:

| Nivel | Varianza σ² | Cálculo | VPC |
|---|---:|---|---:|
| Establecimiento | 8,435 | 8,435 / 15,851 | **53,2 %** |
| Comuna | 2,795 | 2,795 / 15,851 | 17,6 % |
| Región | 1,331 | 1,331 / 15,851 | 8,4 % |
| Residual (mes a mes) | 3,290 | 3,290 / 15,851 | 20,8 % |

(El residual 20,8 % es la oscilación mes a mes *dentro* de un centro; el 53,2 % del establecimiento es la diferencia **estable** entre centros.)

### MOR — "cuánto difieren dos unidades al azar" (la cifra robusta)

**En simple.** Como el VPC depende del supuesto π²/3, usamos el **MOR**: *si tomo dos centros al azar y mando al mismo paciente a los dos, ¿cuánto difieren sus probabilidades de registrarlo?* MOR = 1 sería "no hay diferencia"; cuanto más alto, más importa ese nivel.

**Cálculo (técnico).** `MOR = exp( √(2·σ²) · 0,6745 )`, donde 0,6745 es el percentil 75 de la normal estándar (Merlo et al. 2006). Para el establecimiento:

```
MOR = exp( √(2 × 8,435) × 0,6745 ) = exp( 4,107 × 0,6745 ) = exp(2,770) = 15,96
```

| Nivel | σ² | MOR |
|---|---:|---:|
| **Establecimiento** | 8,435 | **15,96** |
| Comuna | 2,795 | 4,93 |
| Región | 1,331 | 3,01 |

**Lectura del MOR ≈ 16.** Dos centros cualesquiera de la misma comuna difieren, en la mediana, **16 veces** en sus odds de registrar demencia. Es una diferencia enorme; el centro pesa mucho más que el territorio (MOR comuna ~5, región ~3).

---

## 2.5 El resultado, nivel por nivel

**En simple.** La conclusión es nítida y las dos métricas coinciden:

- **El establecimiento manda** (53 % de la variación, MOR ~16). Lo que más determina si tu demencia queda registrada es **a qué centro concreto llegas**.
- **El territorio importa, pero menos** (comuna 17,6 % + región 8,4 % ≈ 26 %). No es despreciable.
- **La red administrativa pesa más que la geografía:** en un modelo alternativo, el **Servicio de Salud** explica **13,5 %** (MOR 4,2), más que la región geográfica (8,4 %). Importa más *bajo qué administración* está el centro que *en qué punto del mapa*.

Ambos modelos **convergieron** (registrado en `productos/modelo_estado.csv`): la licencia para interpretar las cifras.

---

## 2.6 Qué implica para cada lector

**Para la sociedad civil.** Que el sistema "vea" tu demencia depende sobre todo de **a qué centro te toca ir** —más que de tu región—. Es una *lotería de establecimiento*, y eso es una forma de inequidad.

**Para tomadores de decisiones.** La palanca de mayor rendimiento es **centro a centro** (registro, capacitación, sistemas de información, supervisión por establecimiento). Las campañas puramente regionales rinden poco. El **Servicio de Salud** sí es una unidad de gestión con tracción real. En síntesis: **gestión de establecimientos coordinada por Servicio de Salud**, antes que intervenciones regionales genéricas.

**Para la academia.** Partición de varianza de un logístico vacío de tres niveles; VPC con convención π²/3 acompañado de MOR (independiente de esa convención). Los dos modelos (región vs Servicio de Salud) son especificaciones alternativas no anidadas. Convergencia verificada.

---

## 2.7 Cómo encaja con la Parte 1 (coherencia entre métodos)

Una señal de robustez: el multinivel **reconcilia** hallazgos de métodos distintos.

- La **Fase 3** mostró subregistro muy desigual entre tipos de centro (CESFAM 5 % vs postas 23 %): variación a nivel de establecimiento → coherente con el **53 % del establecimiento**.
- La **Parte 1** mostró agrupación geográfica (Moran 0,23): variación territorial → coherente con el **26 % de comuna + región**.

Parecían en tensión; el multinivel los pone en proporción: **predominantemente institucional, con un componente territorial real**. Ningún método solo lo habría mostrado; la consistencia entre ellos da confianza.

---

## 2.8 Caveats de la Parte 2 (declarar siempre)

- **Escala latente.** El VPC vive en la escala latente del logístico, no en probabilidades; por eso se acompaña del MOR. El π²/3 es convención (Goldstein et al. 2002), no estimación.
- **Modelo no condicionado.** Reparte *toda* la variación, no la "ajustada por" tipo de centro o ruralidad: dice *dónde* vive la variación, no *por qué* (eso requeriría predictores; al añadirlos, la escala logística se reescala —Mood 2010— y los VPC se leen cualitativamente).
- **El desenlace es visibilidad administrativa**, no calidad clínica: un centro podría atender bien y registrar mal. El dato no distingue "no hubo actividad" de "hubo y no se registró".
- **Universo** acotado a APS activos; no habla de especialidad/hospitales/privados.

---

## Apéndice · especificación formal y referencias

**Modelo (Parte 2).** `Y ~ Bernoulli(π); logit(π) = β₀ + u_k + u_jk + u_ijk`, con `u ~ N(0, σ²)` por nivel; máxima verosimilitud con Laplace (`glmmTMB`). Principal: región/comuna/establecimiento. Alternativo: Servicio de Salud/comuna/establecimiento. Cifras de `productos/multinivel_q6.csv`: σ²_estab=8,435; σ²_comuna=2,795; σ²_región=1,331; σ²_SS=2,255; N=24.324; centros=2.027; tasa de registro=39,9 %.

**Datos (Parte 1).** Numerador: REM serie P, `P6222300`+`P6223310`, 65+, corte diciembre (`productos/brecha_comuna.csv`). Denominador: proyecciones INE base 2017 (Pob. 2025) × prevalencia 10/66 ajustada urbano/rural (Censo 2017) × cobertura FONASA APS 60+. Espacial: `spdep` (Moran/LISA), geometrías `chilemapas`.

**Referencias.** Snijders & Bosker (2012), *Multilevel Analysis*. Merlo et al. (2006), *J Epidemiol Community Health* (MOR/ICC en epidemiología). Goldstein, Browne & Rasbash (2002) (VPC en modelos no lineales). Mood (2010) (reescalamiento logístico). Estudio 10/66 sobre prevalencia de demencia en Chile. INE, Proyecciones de población base 2017. FONASA, inscritos APS 2025.

**Reproducibilidad.** `source("R/06_analisis_deteccion.R")` (Parte 1) y `source("R/09_sintesis.R")` (Parte 2).

---

# Parte 3 · La cascada de atención (¿se puede seguir a las personas?)

## 3.1 La pregunta

**En simple.** Lo ideal sería seguir el camino de una persona: alguien **sospecha** que tiene demencia → se **diagnostica** → **ingresa** a un programa → queda **bajo control** → si avanza, recibe **cuidado domiciliario**. ¿Permite el REM seguir ese camino y ver *dónde se pierde la gente*?

## 3.2 Las cifras

| Etapa | País | Urbano | Rural | Mixto |
|---|---:|---:|---:|---:|
| 1. Sospecha (A06 consultorías) | 325 | 57 | 89 | 49 |
| 2. Diagnóstico (A06 consultorías) | 467 | 98 | 114 | 72 |
| 3. Ingreso a salud mental (A05, flujo anual) | 15.117 | 3.645 | 1.243 | 2.390 |
| 4. Bajo control (P6, stock diciembre) | 14.514 | 3.776 | 1.710 | 2.065 |
| 5. Domiciliaria, dependencia severa con demencia (P3, stock) | 23.209 | 5.177 | 3.009 | 4.461 |

## 3.3 El hallazgo: los registros no forman un embudo

**En simple.** El camino **no se puede seguir**. Si fuera un embudo, cada paso debería ser menor que el anterior (de muchos sospechosos a pocos en cuidado domiciliario). No es así: el registro de **sospecha y diagnóstico es minúsculo** (325 y 467 personas en todo el país), muchísimo menor que los 15 mil ingresos o los 14 mil bajo control. El **primer escalón del camino prácticamente no se anota**. Y la última etapa (cuidado domiciliario, 23 mil) es **mayor** que el bajo control de salud mental (14,5 mil).

**Por qué pasa esto (técnico).** Las etapas no anidan porque **miden cosas distintas**: la sospecha/diagnóstico es una columna marginal de consultorías de salud mental (un registro muy específico y subutilizado); el ingreso es un **flujo anual**; el bajo control es un **stock semestral**; el cuidado domiciliario es un registro de **dependencia severa** (programa PADDS) que captura casos avanzados que no necesariamente están bajo control de salud mental. Son poblaciones y unidades diferentes, no una misma cohorte seguida en el tiempo. Es, por tanto, un **resultado limitante** (de los que conviene declarar): el REM, tal como está, **no permite reconstruir la ruta de atención**.

**Qué implica para la política.** Dos cosas accionables: (1) si se quiere **monitorear la ruta** de la demencia, hay que **fortalecer el registro de sospecha y diagnóstico** en atención primaria, que hoy es casi inexistente; (2) que el registro de **cuidado domiciliario supere al de bajo control SM** sugiere que muchas personas con demencia avanzada son visibles para el sistema **solo cuando ya hay dependencia severa**, no antes — una detección tardía.

---

# Parte 4 · Equidad: ¿la brecha es más profunda para algunos grupos?

## 4.1 La pregunta

**En simple.** La brecha de detección, ¿es peor para las personas **más pobres**, o para los **pueblos originarios** y los **migrantes**? Lo miramos en dos ejes independientes.

## 4.2 Eje pobreza (tramo A de FONASA = indigencia)

| Comunas, de menos a más pobres | Indigencia media | Tasa de detección | Brecha |
|---|---:|---:|---:|
| Q1 (menos pobre) | 11 % | 6,4 % | 93,6 % |
| Q2 | 16,5 % | 7,1 % | 92,9 % |
| Q3 | 19,5 % | 6,3 % | 93,7 % |
| Q4 (más pobre) | 26,7 % | **4,7 %** | **95,3 %** |

**En simple.** No hay una línea recta entre pobreza y detección (la correlación estadística es prácticamente **cero**: −0,003). Pero el **cuartil más pobre detecta claramente peor** (4,7 % frente a 6-7 % en el resto). **Interpretación honesta:** la pobreza por sí sola no traza un gradiente; lo que aparece es que las **comunas más pobres tienden a ser rurales**, así que esto es probablemente el **mismo efecto rural** que ya vimos en la Parte 1, más que un efecto independiente de la pobreza.

## 4.3 Eje pueblos originarios y migrantes

| Zona | Personas bajo control | % pueblos originarios | % migrantes |
|---|---:|---:|---:|
| País | 14.514 | 2,42 % | 0,58 % |
| Urbano | 3.776 | 1,59 % | 0,93 % |
| Rural | 1.710 | **6,67 %** | 0,12 % |
| Mixto | 2.065 | 2,28 % | 0,05 % |

**En simple.** Entre las personas con demencia bajo control, **2,4 % son de pueblos originarios** a nivel país, con un patrón territorial nítido: **6,7 % en zonas rurales** (donde vive más población originaria) frente a 1,6 % urbano. Los **migrantes son apenas 0,6 %**, concentrados en ciudades.

**Qué implica y qué falta (técnico).** El 2,4 % nacional **parece bajo** comparado con el peso de la población originaria del país (~13 % en el Censo), lo que **sugiere una posible subdetección** de la demencia en pueblos originarios. Pero es una **hipótesis, no una conclusión**: para afirmarlo hace falta el **denominador poblacional comunal** (cuántas personas mayores de pueblos originarios hay en cada comuna, del Censo 2024), que es el refinamiento pendiente. El eje **migrante** es poco informativo por diseño: la migración chilena es joven y la demencia es de 65+, así que los conteos son muy pequeños (está **subpotenciado**, como se anticipó desde la Fase 0).

**Reglas que respetamos.** Las columnas de pueblos originarios y migrantes son **marginales independientes**: no se cruzan entre sí ni con edad o sexo, y la autoidentificación está sujeta a subregistro. Por eso reportamos composición (porcentajes dentro del bajo control), no tasas cruzadas.

## 4.4 Síntesis de equidad

La inequidad **más fuerte y mejor sustentada es la territorial** (rural), que ya cuantificamos en las Partes 1 y 2. El eje de **pobreza** no agrega un efecto propio claro más allá de su solapamiento con lo rural. El eje de **pueblos originarios** muestra una señal que merece seguimiento (posible subdetección), condicionada a conseguir el denominador del Censo. El eje **migrante** no es informativo para demencia.

---

*Documento completo para las cuatro preguntas del análisis (brecha, multinivel, cascada, equidad). Se actualiza —y el PDF se regenera— si cambian los datos o se incorpora el denominador poblacional del Censo 2024 para el eje de pueblos originarios.*
