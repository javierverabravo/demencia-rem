# Fase 5 · Análisis — Brecha de detección de demencia (pregunta rectora)

> Entregable parcial de la Fase 5 (junio 2026): la **pregunta rectora (Q1)**. Cuánta de la demencia esperada en personas mayores (65+) está bajo control en la red pública de salud mental, dónde está la mayor brecha, y cómo se distribuye en el territorio. Corrido en Positron con `R/06_analisis_deteccion.R`. Salidas: `productos/brecha_comuna.csv`, `productos/deteccion_resumen.csv`, `productos/modelo_estado.csv`.
>
> Las secundarias (Q2 cascada, Q5 equidad, Q6 multinivel) quedan como bloques siguientes del motor.

---

## 1. Definiciones

- **Numerador** (stock): población bajo control SM por demencia, 65+, corte de **diciembre** = `P6222300` (APS) + `P6223310` (Especialidad). Corte único, no suma de semestres.
- **Denominador (primario): demencia esperada en la población del SISTEMA PÚBLICO.** = demencia esperada INE × **cobertura pública** (FONASA inscritos APS 60+ / población INE 60+ por comuna). Corrige el sesgo de contar beneficiarios de isapre que el REM nunca ve. La prevalencia (10/66) va **ajustada urbano/rural** (rural 10,3 % vs urbano 6,3 %, Censo 2017).
- **Denominador (sensibilidad):** demencia esperada sobre población INE **total** (sin descontar isapre).
- **Tasa de detección** = bajo control / esperados. **Brecha** = 1 − tasa.

A nivel país, FONASA cubre el **85,7 %** de los adultos mayores; el resto (isapre) se concentra en comunas urbanas de altos ingresos. Por eso el denominador público (205.843 esperados 65+) es menor que el de población total (244.338).

---

## 2. Resultado nacional

| | Denominador público (FONASA) | Sensibilidad (INE total) |
|---|---:|---:|
| Demencia esperada 65+ | 205.843 | 244.338 |
| Bajo control SM 65+ (dic) | 13.114 | 13.114 |
| **Tasa de detección** | **6,3 %** | 5,4 % |
| **Brecha de detección** | **93,7 %** | 94,6 % |

Con el denominador correcto (población pública), la red de salud mental tiene bajo control **alrededor de 1 de cada 16** personas mayores con la demencia esperada. La brecha del 93,7 % mide lo que el subsistema de salud mental pública **no tiene bajo control** — no demencia "sin atender" (mucha se maneja en APS sin quedar bajo control SM, en el sector privado, o no se detecta). Es una medida de visibilidad del subsistema, y ahí está su valor de política.

---

## 3. Gradiente territorial (el eje de la rectora)

| Zona (prop_rural) | Comunas | Tasa de detección | Brecha |
|---|---:|---:|---:|
| Urbano (≤ 0,10) | 50 | **8,5 %** | 91,5 % |
| Rural (≥ 0,40) | 145 | 4,9 % | 95,1 % |
| Mixto (0,10–0,40) | 113 | 4,4 % | 95,6 % |

Las comunas **urbanas detectan ~1,7 veces más** que las rurales. Al usar el denominador público, el contraste se **agudizó** respecto al primer pase (con población total era 7,1 % vs 4,5 %): quitar la distorsión isapre —que recorta el denominador urbano más que el rural— deja ver una desigualdad territorial mayor y mejor medida. Lo rural sigue **doblemente desfavorecido**: más prevalencia esperada (denominador) **y** más subregistro (Fase 3: postas 23 % vs CESFAM 5 %).

---

## 4. Focos espaciales (Moran global + LISA) — la señal territorial emerge

- **Moran's I = 0,232 (p ≈ 1,6 × 10⁻¹³)**: autocorrelación espacial **fuerte y muy significativa**. **Hallazgo clave:** con el denominador de población total el Moran era débil (0,065); al limpiar el denominador con FONASA, la señal territorial se **cuadruplicó**. La distorsión isapre estaba enmascarando la estructura espacial. La detección **sí** se agrupa geográficamente.
- **LISA**: 6 comunas en clúster **alto-alto** (buena detección agrupada), concentradas en el **sur austral** (Los Lagos y Aysén); 0 clústeres **bajo-bajo** significativos. El problema de baja detección es **generalizado** (no hay bolsones fríos puntuales), pero la buena detección **sí** se concentra territorialmente.
- Caveat: análisis **ecológico** y **MAUP**. En comunas muy chicas el denominador público es pequeño y la tasa puede superar 1 (ruido); no afecta los agregados nacionales/zonales (basados en sumas). La prueba formal de "registro vs geografía" es el multinivel (Q6) — y el Moran fuerte anticipa que la geografía **sí** pesa, a diferencia de lo que sugería el primer pase.

---

## 5. El Plan Nacional de Demencia se ve en la detección

Las comunas con **Centros de Apoyo Comunitario para personas con demencia** (dispositivos especializados del PND, Fase 0 §3.2) **lideran** la detección entre las comunas grandes (65+ > 5.000): **Osorno (27,0 %)** y **Punta Arenas (22,3 %)** encabezan, muy por encima de la media. Donde existe el dispositivo especializado, la red registra bajo control una fracción mucho mayor de la demencia esperada. Señal directa de que **la implementación del programa mueve la aguja** — argumento central para extender el footprint del PND. (El clúster alto-alto del sur austral es consistente con la presencia de dispositivos en Osorno y la zona.)

---

## 6. ¿Dónde vive la variación? — multinivel (Q6)

Modelo logístico de **3 niveles** sobre la **barrera de registro** (¿un establecimiento APS registra actividad de demencia en el mes?), panel de **2.027 centros APS activos × 12 meses** (tasa de registro = 39,9 %). Reparto de la varianza latente (VPC) y MOR por nivel (estimación Laplace; `rem-estadistica` §3-5):

| Nivel | VPC (% varianza) | MOR |
|---|---:|---:|
| **Establecimiento** | **53,2 %** | **15,96** |
| Comuna | 17,6 % | 4,93 |
| Región | 8,4 % | 3,01 |
| (residual latente π²/3) | 20,8 % | — |

**La barrera es predominantemente institucional:** más de la mitad de la varianza vive en el establecimiento, con un MOR de ~16 (dos centros idénticos de la misma comuna difieren ~16 veces en sus odds de registrar demencia). Pero el **territorio no es despreciable**: comuna (17,6 %, MOR 4,9) + región (8,4 %) ≈ 26 % — coherente con el Moran fuerte de §4.

**Modelo alternativo** (Servicio de Salud en vez de región): el **Servicio de Salud explica 13,5 %** (MOR 4,19), más que la región geográfica (8,4 %) → la **red administrativa pesa más que la geografía pura** (a diferencia del 0-2 % nulo que el Servicio de Salud mostró en el proyecto A19b). Ambos modelos **convergieron**.

**Lectura de política:** la palanca principal es **centro a centro** (por qué unos CESFAM/postas registran y otros no — la pregunta del MOR 16), pero las intervenciones por **comuna** y por **Servicio de Salud** también tienen tracción real. El resultado **reconcilia** los hallazgos previos: el subregistro institucional de la Fase 3 (CESFAM 5 % vs postas 23 %) explica el dominio del establecimiento; el Moran 0,23 explica el ~26 % territorial.

---

## 7. Caveats (declarar siempre)

- El numerador es **bajo control SM** (`P6`), no toda la atención de demencia: la brecha mide lo que el subsistema SM no tiene bajo control, no demencia sin ningún contacto.
- El subregistro rural (Fase 3) infla la brecha rural: parte del gradiente es registro, no solo detección real.
- Prevalencia 10/66 e INE base 2017 (pre-Censo 2024); cobertura pública FONASA por bandas de 10 años (escalada vía 60+). Denominador con incertidumbre.
- Ecológico + MAUP; tasas comunales no interpretables a nivel individual; comunas chicas con tasa > 1.

---

## 8. Secundarias cerradas: cascada (Q2) y equidad (Q5)

**Q2 cascada** (`productos/cascada.csv`; detalle en `FUNDAMENTACION_ESTADISTICA.md` Parte 3). Las etapas **no anidan** en un embudo: sospecha 325 · diagnóstico 467 · ingreso SM 15.117 · bajo control 14.514 · domiciliaria 23.209. Son registros con lógicas distintas (flujo vs stock, marginal vs eje, poblaciones distintas), no una cohorte. **Hallazgo limitante:** el registro formal de sospecha/diagnóstico es minúsculo → el REM no permite reconstruir la ruta de atención, y la detección parece **tardía** (el registro domiciliario de dependencia severa supera al bajo control SM).

**Q5 equidad** (`productos/equidad_pobreza.csv`, `equidad_origen.csv`; Parte 4). (a) **Pobreza**: sin gradiente suave (Spearman −0,003), pero el cuartil más pobre detecta peor (4,7 % vs 6-7 %) → probablemente confundido con ruralidad, no efecto pobreza propio. (b) **Pueblos originarios**: 2,4 % del bajo control país, 6,7 % en rural; parece bajo vs el ~13 % poblacional → posible subdetección (hipótesis, pendiente denominador Censo 2024). **Migrantes** 0,6 %, subpotenciado como se anticipó.

## 9. Pendiente de Fase 6

- Llevar la brecha al **mapa** (página Territorio del dashboard) y publicar el sitio.
- Refinamiento opcional: denominador poblacional Censo 2024 para el eje de pueblos originarios.

---

## 9. Bitácora (añadir al README §8)

| Fecha | Decisión / Hallazgo | Detalle |
|---|---|---|
| 2026-06-10 | **Fase 5 rectora (Q1) entregada** (ver `FASE_5_ANALISIS.md`) | Brecha de detección país = **93,7 %** (denominador público FONASA; 13.114 bajo control 65+ vs 205.843 esperados) |
| 2026-06-10 | **Denominador público FONASA** (inscritos APS 60+, cobertura 85,7 %) como primario; INE total como sensibilidad | El REM solo mide la red pública; contar isapre inflaba la brecha (94,6 % → 93,7 %) |
| 2026-06-10 | **Gradiente territorial agudizado**: detección urbano 8,5 % vs rural 4,9 % (~1,7×) | El denominador público hace justa la comparación; lo rural es doblemente desfavorable |
| 2026-06-10 | **Moran's I = 0,232 (p≈10⁻¹³)**, fuerte (vs 0,065 con población total) | Limpiar el denominador reveló la estructura espacial; el territorio sí pesa (a confirmar en Q6) |
| 2026-06-10 | **PND visible**: Osorno (27,0 %) y Punta Arenas (22,3 %), sedes de Centros de Apoyo Comunitario, lideran; clúster alto-alto en el sur austral | La implementación del programa mueve la detección → argumento para extender el footprint |
| 2026-06-10 | **Q6 multinivel resuelto**: la barrera de registro es **predominantemente institucional** (establecimiento 53,2 % de la varianza, MOR 15,96) con territorio no trivial (comuna+región ≈26 %) | Palanca principal centro a centro; comuna y Servicio de Salud (13,5 %) con tracción secundaria. Reconcilia Fase 3 (institucional) y Moran (territorial) |
