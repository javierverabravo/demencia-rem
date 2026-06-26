# Diseño de aplicación — Priorización de establecimientos para cerrar la brecha de detección de demencia

> Documento de diseño (no construcción). Décimo eslabón de la cadena (`construir-app-shiny`): la app consume los productos del pipeline; no recalcula el análisis en vivo. Audiencia: gestores de Servicios de Salud y nivel central (MINSAL). Tarea central: decidir **qué establecimientos intervenir primero** para mejorar el registro y la detección de demencia.

## 1. Propósito y justificación

El hallazgo rector del análisis es que la variación en el registro de demencia es **predominantemente institucional**: el establecimiento explica el 53% de la varianza (MOR ≈ 16) y el Servicio de Salud pesa más que la región geográfica. La consecuencia operativa es que la palanca de mayor rendimiento es **centro a centro, coordinada por Servicio de Salud**, no la campaña regional genérica. Un informe estático ya comunica esto; lo que el informe no puede hacer —y justifica una app— es permitir que cada gestor **explore su propio Servicio, baje al establecimiento, filtre por contexto y obtenga una lista accionable y recurrente**. La interacción agrega valor real (muchos cortes, el caso propio del usuario, uso periódico), que es el criterio para construir una app y no un informe fijo.

## 2. Usuario y tareas

Usuario: encargado de salud mental / gestión de red de un Servicio de Salud, y su equivalente en el nivel central.

Tareas (definen las vistas, no al revés):

- **T1.** Ver la brecha de mi Servicio de Salud frente al país y a otros Servicios.
- **T2.** Obtener un **ranking de establecimientos prioritarios** de mi red, ajustado por contexto.
- **T3.** Entender **por qué** un establecimiento está bajo (subregistro vs volumen vs ruralidad vs ausencia de dispositivo del Plan Nacional de Demencia).
- **T4.** **Exportar** la lista priorizada para planificar capacitación, supervisión o sistemas de información.
- **T5.** Seguir la evolución en el tiempo (semestre a semestre, año a año).

## 3. El indicador central: priorización de establecimientos

El núcleo de la app es un **puntaje de prioridad por establecimiento**, calculado en el pipeline (no en la app). Combina tres componentes, todos ya derivables del análisis:

1. **Déficit de registro ajustado por contexto.** Es el efecto aleatorio del establecimiento (intercepto del modelo multinivel de `09_sintesis.R`): cuánto registra de menos un centro respecto de lo esperado para su comuna y región. Aísla el componente institucional puro, que es justamente lo intervenible.
2. **Volumen de población expuesta.** Inscritos FONASA 60+ del centro (`centros_geo.csv`): un déficit en un centro grande afecta a más personas que el mismo déficit en uno pequeño.
3. **Ponderador de equidad territorial (opcional, decisión humana).** Realce de lo rural, dado que el subregistro rural es mayor (postas 23% vs CESFAM 5%) y la prevalencia esperada es más alta.

Puntaje = función monótona de (déficit × volumen × ponderador). El centro ideal a intervenir primero es el que **podría registrar mucho más y atiende a mucha gente**. El detalle de la fórmula y los pesos es un **punto de decisión humana** (sección 10): la app expone los componentes por separado para que el gestor no reciba una caja negra.

Salvaguardas del indicador:

- Solo **APS activos** (separa cero estructural de subregistro; ya acotado en el pipeline).
- El desenlace es **visibilidad administrativa del registro, no calidad clínica**: un centro puede atender bien y registrar mal. Debe declararse en cada vista.
- No penalizar a un centro por ausencia de programa que no le corresponde (tipo de establecimiento sin la prestación por diseño).

## 4. Arquitectura de información y navegación

Layout `bslib` con barra de navegación superior y un selector global persistente de **Servicio de Salud** (estado compartido). El mensaje principal es visible sin interactuar; el detalle, a un clic.

- **Resumen.** Mensaje principal arriba: brecha del país y del Servicio seleccionado, con su intervalo de incertidumbre (de `sensibilidad_prevalencia.csv`). Tres indicadores grandes: brecha, tasa de detección, nº de establecimientos prioritarios. Una frase de lectura honesta ("mide visibilidad del subsistema, no demencia total").
- **Priorización** (vista principal). Tabla rankeada de establecimientos del Servicio seleccionado (T2) + mapa de puntos sincronizado. Filtros: comuna, tipo de centro, ruralidad, presencia de dispositivo del Plan Nacional. Columnas: centro, comuna, tipo, inscritos 60+, déficit de registro, volumen bajo control, puntaje, prioridad. Botón **Exportar** (CSV).
- **Ficha de establecimiento** (drill, T3). Al hacer clic en un centro: su serie de registro mensual, su subregistro, su contexto (comuna, Servicio, rural/urbano, dispositivo PND), y su comparación contra **pares del mismo tipo y zona**. Explica por qué está donde está.
- **Territorio.** Mapa comuna (brecha enmascarada en celdas pequeñas) y capa de centros; gradiente urbano/rural; footprint del Plan Nacional. Reusa la lógica del dashboard actual (`territorio.qmd`).
- **Metodología y caveats.** Cómo se calcula el puntaje, supuestos, incertidumbre, y los límites (administrativo ≠ clínico; subregistro rural; denominador). Enlaces a `FUNDAMENTACION_ESTADISTICA.pdf`, `estado_del_arte.md` y al repositorio.

## 5. Contrato de datos

La app **consume** artefactos de `productos/`; cualquier agregado nuevo se computa en el pipeline.

Ya disponibles:

- `centros_geo.csv` — centros georreferenciados con bajo control 65+, detección, inscritos 60+, tipo, comuna.
- `brecha_comuna.csv` — brecha comunal con columnas enmascaradas (`tasa_deteccion_pub`, `brecha_pub`) para celdas pequeñas.
- `deteccion_resumen.csv` — brecha país y por zona.
- `cobertura_subregistro.csv` — subregistro por tipo/nivel de establecimiento.
- `sensibilidad_prevalencia.csv` — intervalo de incertidumbre de la brecha.
- `multinivel_q6.csv` — componentes de varianza.

**Nuevo artefacto requerido (prerrequisito de construcción):** `productos/ranking_establecimientos.csv`, generado extendiendo `09_sintesis.R` para exportar el **efecto aleatorio por establecimiento** (BLUP del intercepto) junto con su contexto (comuna, Servicio de Salud, región, rural, flag PND), inscritos 60+, volumen bajo control y el puntaje de prioridad. Es el insumo de la vista de Priorización y de la Ficha. Se computa en el pipeline, una vez, no en la app.

## 6. Arquitectura técnica

Stack: `shiny`, `bslib` (layout y tema), módulos de Shiny (`moduleServer`), `reactable` o `DT` (tabla), `leaflet` (mapa, ya en uso), `ggiraph`/`plotly` (gráficos de la ficha), `shinytest2` (pruebas), `renv` (entorno fijado, ya inicializado).

Módulos (uno por componente funcional):

- `mod_filtro_global` — selector de Servicio de Salud / comuna; expone el estado compartido.
- `mod_resumen` — indicadores y mensaje principal.
- `mod_priorizacion` — tabla rankeada + mapa sincronizado + exportación.
- `mod_ficha_estab` — drill de un establecimiento y comparación con pares.
- `mod_territorio` — mapa comuna/centro.
- `mod_metodo` — metodología y caveats.

Reactividad con intención: el ranking llega precomputado; el filtrado es `reactive()` sobre la tabla en memoria; `bindCache()` por Servicio/comuna; nada de recalcular modelos en vivo. Trabajo pesado (BLUPs, puntaje) en el pipeline.

## 7. Fidelidad a la evidencia, ética y celdas pequeñas

- **Incertidumbre visible:** la brecha se muestra con intervalo (no punto); los puntajes con su limitación de interpretación.
- **Celdas pequeñas:** se reusa el resguardo del pipeline (no mostrar tasa cuando hay menos de 5 personas bajo control; comunas con denominador chico marcadas). Ningún filtro debe permitir reidentificar: las marginales de pueblos originarios/migrantes **no** se exponen a nivel de centro ni comuna, solo agregadas (como en el análisis).
- **Aviso de muestra pequeña:** cuando un filtro reduce la vista a pocos centros o personas, la app lo advierte en vez de dejar concluir de más.
- **Administrativo ≠ clínico:** rótulo persistente de que el indicador mide registro, no calidad de atención.
- **Saneamiento de entradas:** validar selecciones; `req()` y estados vacíos claros.

## 8. Accesibilidad y estados

Contraste WCAG, paletas seguras para daltonismo (la misma del dashboard), navegación por teclado, textos alternativos en figuras y mapa. Indicadores de carga, estado vacío ("selecciona un Servicio") y estado de error explícitos.

## 9. Pruebas y despliegue

- `shinytest2` para regresión de la UI; pruebas unitarias de la lógica de cada módulo (filtrado, puntaje, exportación).
- Entorno fijado con `renv` (ya inicializado).
- Despliegue: shinyapps.io o Posit Connect para acceso de gestores; alternativamente contenedor. Si la app maneja datos solo agregados y públicos, el despliegue abierto lo formaliza `publicar-abierto`; si incluyera cortes finos, se restringe el acceso. Decisión en sección 10.

## 10. Puntos de decisión humana

1. **Pesos del puntaje de prioridad** (déficit vs volumen vs realce rural): es una decisión de política, no técnica. La app debe permitir ver el efecto de cada ponderador; los valores por defecto los aprueba el equipo.
2. **Acceso público vs interno:** una lista de "centros con bajo registro" es sensible reputacionalmente. Definir si la app es interna (gestión) o pública (transparencia), y qué nivel de detalle se expone en cada caso.
3. **Marco de lectura:** acordar el lenguaje que evita leer "bajo registro" como "mala atención".

## 11. Plan de construcción por fases (cuando se apruebe)

1. **Pipeline:** extender `09_sintesis.R` → `productos/ranking_establecimientos.csv` (BLUPs + contexto + puntaje).
2. **Esqueleto:** app `bslib` con navbar, filtro global y las cinco vistas vacías.
3. **Vista Priorización** (la de mayor valor) con tabla + mapa + exportación.
4. **Ficha de establecimiento** y comparación con pares.
5. **Resumen y Territorio** (reusan productos y lógica existentes).
6. **Fidelidad, accesibilidad, pruebas** (`shinytest2`) y despliegue.

## Referencias

Hallazgos y cifras: `FUNDAMENTACION_ESTADISTICA.pdf`, `auditoria.md`, `estado_del_arte.md`. Productos del pipeline: carpeta `productos/`. Disciplina de diseño: skill `construir-app-shiny`.
