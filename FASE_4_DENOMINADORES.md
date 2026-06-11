# Fase 4 · Denominadores — demencia esperada por comuna

> Entregable de la Fase 4 (junio 2026). Construye el denominador de la pregunta rectora: la **demencia esperada** en población de 65+ por comuna, a partir de las proyecciones de población del INE y la prevalencia por banda etaria del estudio 10/66 Chile. Corrido en Positron con `R/03_denominadores.R`. Salida: `productos/denominadores.csv`.

---

## 1. Fuente y método

**Población:** proyecciones INE base 2017, nivel comunal, 2002-2035 (Excel oficial, comuna × sexo × edad × año; 10,5 MB). Se usa la columna **Población 2025** para empatar con el año del REM. Lectura robusta (detecta fila de encabezado y columnas), reshape a banda etaria.

**Prevalencia:** estudio **10/66 Chile** por banda etaria (FASE_0 §3.1):

| Banda | 60-64 | 65-69 | 70-74 | 75-79 | 80-84 | ≥85 |
|---|---:|---:|---:|---:|---:|---:|
| Total | 1,2 % | 4,1 % | 3,7 % | 8,8 % | 19,4 % | 32,6 % |

**Demencia esperada** (comuna) = Σ_banda [ población_banda × prevalencia_banda ]. La estructura de edad hace el grueso del trabajo: la prevalencia crece de 4 % a 33 % entre los 65 y los 85+, así que las comunas envejecidas concentran más casos esperados.

---

## 2. Resultados

| Indicador (país, 2025) | Valor |
|---|---:|
| Comunas con denominador | 346 |
| Población 60+ | 3.988.537 |
| Población 65+ | 2.876.236 |
| **Demencia esperada 60+** | **254.337** |
| **Demencia esperada 65+** | **240.980** |

La prevalencia implícita 65+ es 240.980 / 2.876.236 = **8,4 %**, coherente con el 7,0 % global 60+ del 10/66 (la tasa sube al restringir a 65+). Las comunas con más casos esperados en términos absolutos son las más pobladas (Viña del Mar, Las Condes, Maipú, La Florida, Valparaíso, Puente Alto) — el análisis relevante es **per cápita / brecha**, que se hace en Fase 5.

**Cruce comunal REM ↔ INE = 100 %**: todas las comunas que aparecen en el REM tienen denominador. El numerador (bajo control) y el denominador (esperado) se cruzan sin pérdida.

---

## 3. Primer contraste numerador vs denominador (preview de la rectora)

Orden de magnitud, a formalizar en Fase 5: el numerador limpio es la población **bajo control SM por demencia** (`P6222300` APS + `P6223310` Especialidad), 65+, en un corte semestral. El stock 65+ bajo control ronda las **~13.000 personas** frente a **~241.000 esperadas** → una **brecha de detección del orden del 95 %**: la red pública de salud mental tiene bajo control una fracción pequeña de la demencia esperada en personas mayores.

Esto es coherente con la naturaleza del REM (solo ve a quien contacta el sistema **y queda registrado bajo control SM**; mucha demencia se maneja en otros dispositivos, en el sector privado, o no se detecta). La cifra exacta, su intervalo y su lectura territorial (dónde la brecha es mayor) son el producto de la Fase 5. **No es una medida de mala praxis**: es la distancia entre lo esperado epidemiológicamente y lo que el sistema público registra bajo control.

---

## 4. Decisiones y caveats

- **Corte único, no suma de cortes.** El denominador es prevalencia (stock). El numerador debe ser el **stock bajo control en un corte** (p. ej. diciembre), no la suma de junio + diciembre (que duplicaría). Fijar en Fase 5.
- **Ajuste urbano/rural pendiente (el eje territorial de la rectora).** Hoy la demencia esperada usa la prevalencia **total** por banda. El 10/66 muestra rural 10,3 % vs urbano 6,3 %: aplicar ese diferencial sube la demencia esperada en comunas rurales y, combinado con el subregistro rural detectado en Fase 3 (postas 23 %), es el corazón del hallazgo territorial. El script ya está listo para activarlo: basta dejar `datos/externos/comunas_urbano_rural.csv` (`cod_comuna`, `prop_rural`, del Censo 2024) y vuelve a correr — mezcla automáticamente las prevalencias. **Este es el principal pendiente de Fase 4.**
- **Base 2017 vs Censo 2024.** Las proyecciones son base 2017 (las oficiales vigentes a nivel comunal por edad). Cuando el INE publique proyecciones base Censo 2024 por comuna y edad, reemplazar la fuente; declarar la base usada.
- **FONASA inscritos APS (incorporado).** Se añadió el denominador del **subsistema público**: `03_denominadores.R` cruza el archivo de inscritos APS (código de centro → maestro → comuna), agrega inscritos 60+ por comuna y calcula la **cobertura pública** (FONASA 60+ / INE 60+ = 85,7 % país) para escalar la demencia esperada 65+ a la población que el sistema público efectivamente ve. Esto corrige el sesgo de contar beneficiarios de isapre (que el REM nunca registra), concentrados en comunas urbanas. Demencia esperada 65+ **pública = 205.843** (vs 244.338 con población total). Además deja `tramo_a_pct` (indigencia FONASA) como proxy de pobreza comunal para la equidad (Q5). El denominador público pasa a ser el **primario** de la rectora; el de población total queda como análisis de sensibilidad.
- **CASEN**: covariable de pobreza opcional (degradación elegante); el `tramo_a_pct` de FONASA ya cubre parte de esto.

---

## 5. Pendientes para Fase 5

- Conseguir `comunas_urbano_rural.csv` (Censo 2024) y activar el ajuste territorial de prevalencia.
- Fijar el numerador en un corte semestral; calcular brecha = 1 − bajo_control_65 / demencia_esperada_65 por comuna.
- Llevar la brecha al mapa (Moran/LISA) y leer el diferencial urbano/rural.

---

## 6. Bitácora (añadir al README §8)

| Fecha | Decisión | Razón |
|---|---|---|
| 2026-06-10 | **Fase 4 cerrada** (ver `FASE_4_DENOMINADORES.md`): demencia esperada por comuna desde INE base 2017 + prevalencia 10/66 | Denominador de la brecha de detección |
| 2026-06-10 | Demencia esperada 65+ país = **240.980** (8,4 % de 2,88 M); **cruce comunal REM↔INE = 100 %** | Numerador y denominador cruzan sin pérdida |
| 2026-06-10 | Preview brecha rectora ≈ **95 %** (≈13 mil bajo control vs ≈241 mil esperados) | Magnitud de lo que el sistema público SM no tiene bajo control; formalizar en Fase 5 |
| 2026-06-10 | Numerador = **stock de un corte** (no suma jun+dic); ajuste urbano/rural pendiente de `comunas_urbano_rural.csv` | Evitar doble conteo; activar el eje territorial de la rectora |
