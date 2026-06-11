# Fase 3 · Panel y diagnóstico — cobertura y subregistro

> Entregable de la Fase 3 (junio 2026). Cruza el universo demencia con la base maestra de establecimientos del DEIS, reconstruye el panel establecimiento × período y mide cobertura, subregistro e intensidad por tipo y nivel de establecimiento, separando el **cero estructural** (centro sin el programa por diseño) del **subregistro** (centro que debería registrar y no lo hace). Corrido en Positron con `R/00_descarga.R` + `R/01b_panel.R`. Salidas: `productos/join_diagnostico.csv`, `productos/cobertura_subregistro.csv`.

---

## 1. Cruce REM ↔ base maestra: limpio al 100%

| ids REM | match código nuevo | match código antiguo | clave |
|---|---:|---:|---|
| 2.983 | **100,0 %** | 0,0 % | `cod_estab` |

Los 2.983 establecimientos que aparecen en el REM (todas las series) cruzan **exactamente** con el código vigente (`EstablecimientoCodigo`) de la base maestra del DEIS (5.644 establecimientos vigentes, datos.gob.cl, CC-Zero). El panel se construye sobre una base sólida: ningún establecimiento del REM queda sin atributos (tipo, nivel, dependencia, comuna, Servicio de Salud).

---

## 2. Hallazgo metodológico central: stock vs evento en el denominador

El "subregistro temporal" se calcula como `1 − períodos observados / períodos esperados`. Los **períodos esperados** son 2 para la Serie P (stock semestral) y 12 para A/BS (mensual). **Esto solo es interpretable como subregistro real en las series de stock.**

- **Series de stock (P)**: un establecimiento con personas bajo control por demencia **debería** reportar en **ambos** cortes (junio y diciembre). Si falta uno, es subregistro genuino. → el denominador de 2 es correcto.
- **Series de evento (A05 ingresos/egresos, A06 evaluaciones, A28 actividades)**: un establecimiento **no ingresa** a una persona con demencia todos los meses. Un "subregistro" del 62 % en ingresos significa que el centro registró ingresos en ~4,6 de 12 meses — lo cual es **esperable**, no falta de dato. → el denominador de 12 **sobrestima** la expectativa; el % alto es dispersión de eventos, no subregistro.

**Consecuencia para Fase 5:** la métrica de completitud temporal se aplica a P (stock); para los bloques de evento de la Serie A se usa cobertura (¿registró alguna vez?) e intensidad, no el % sobre 12 meses.

---

## 3. Calidad del numerador rector (P6222300, bajo control SM, stock semestral)

Aquí el subregistro **sí** mide completitud, y el resultado es bueno donde concentra el volumen:

| Tipo de establecimiento | Estab. | Subregistro | Intensidad | Volumen |
|---|---:|---:|---:|---:|
| **CESFAM** | 545 | **5,0 %** | 20,0 | 20.713 |
| Posta de Salud Rural (PSR) | 398 | 23,1 % | 2,0 | 1.249 |
| CECOSF | 185 | 15,9 % | 4,1 | 1.279 |
| Hospital | 55 | 3,6 % | 16,2 | 1.713 |
| Hospital (primario) | 17 | 8,8 % | 15,3 | 475 |
| resto (CGR, COSAM, CGU, PRAIS…) | 24 | variable | — | ~460 |

El grueso del numerador vive en **CESFAM (545 establecimientos, 80 % del volumen) con apenas 5 % de subregistro** → reportan en ambos cortes casi sin falta. El numerador de la brecha de detección es **confiable**. La señal de subregistro real se concentra en las **postas rurales (PSR, 23 %)**: justamente las comunas rurales donde la prevalencia esperada es mayor (10,3 % vs 6,3 % urbano, Fase 0) → el subregistro rural **agranda** la brecha estimada y hay que declararlo como caveat (parte de la "brecha" rural es subregistro, no solo demencia sin detectar). `P3171613` (apoyo domiciliario) confirma el patrón: CESFAM 3,7 % de subregistro, PSR 18,6 %.

---

## 4. Dónde vive la demencia (cero estructural por tipo de establecimiento)

El panel muestra en qué tipos de centro se registra cada bloque — esto delimita el cero estructural:

- **APS (CESFAM, PSR, CECOSF)**: concentra detección, bajo control y atención domiciliaria. Es el corazón del numerador.
- **Hospitales (incl. terciarios)**: aparecen en estimulación cognitiva con **volumen e intensidad muy altos** (`28021500`: Hospital terciario, 77 establecimientos, intensidad media **514**, 448.323 atenciones, subregistro 5,6 %) → la rehabilitación cognitiva intensiva es hospitalaria, no de APS. Bloque aparte en su propia lógica.
- **Dispositivos especializados del Plan Nacional de Demencia visibles en el dato**: el tipo **"Centro de Apoyo Comunitario para Personas con Demencia"** aparece de forma consistente y con baja completitud-faltante e intensidad alta en ingresos/egresos SM, evaluaciones PND y P6223310 (Especialidad) — son los ~7 centros del footprint PND (Fase 0 §3.2). Además, **hospitales terciarios** con intensidad altísima en las evaluaciones PND (`06906135`: Hospital terciario, 2 establecimientos, intensidad 64,5) son las **Unidades de Memoria**. → insumo directo del overlay territorial del PND.
- **Ruido a filtrar**: tipos con 1-2 establecimientos y volumen ~0 (Clínica Dental, Unidad de Procedimientos Móvil, "Otro") registrando un código de demencia son casi seguro error de registro; se marcan y excluyen del universo esperado.

---

## 5. A06 Secc. F (PND) y cuidadores — confirmación de baja cobertura

- `06906135` (reevaluación GDS): 93 CESFAM + 4 Centros de Apoyo Comunitario + 2 hospitales terciarios de altísima intensidad. Cobertura baja y concentrada, como anticipó la Fase 0.
- `06906145` (satisfacción cuidador): apenas **12 CESFAM + 5 otros** establecimientos en todo el país. → Q4 cuidadores se mantiene **exploratoria**: el dato existe pero es demasiado ralo para inferencia.

---

## 6. Decisiones para Fase 4-5

- **Numerador rector**: `P6222300` (APS) + `P6223310` (Especialidad), sumados; confiable (CESFAM 5 % de subregistro). Declarar el subregistro rural (PSR 23 %) como caveat que infla la brecha en comunas rurales.
- **Universo esperado (cero estructural)**: restringir a APS (CESFAM, PSR, CECOSF, CGR, CGU) para población bajo control + Hospitales/COSAM/Centros de Apoyo para el componente especializado. Excluir tipos de volumen ~0 (error de registro).
- **Métrica de completitud**: subregistro temporal solo para Serie P (stock); para A/BS de evento, cobertura + intensidad.
- **Modelos (confirmar en Fase 5 con `rem-estadistica`)**: el panel confirma exceso de ceros estructurales (muchos tipos sin el programa) + sobredispersión → para los conteos, hurdle/binomial negativa con el universo esperado como base de exposición; para P, tasas con offset poblacional (Fase 4).
- **Overlay PND**: usar los tipos "Centro de Apoyo Comunitario para Personas con Demencia" y los hospitales con Unidad de Memoria como capa territorial del programa especializado.

---

## 7. Pendientes para Fase 4

- Denominadores INE 65+ comunales × prevalencia (10/66) → demencia esperada por comuna (numerador rector / esperado = brecha).
- Clasificación urbano/rural comunal (el eje territorial; el subregistro rural ya muestra por qué importa).
- Listado nominal de los Centros de Apoyo Comunitario y Unidades de Memoria para fijar las comunas del programa especializado (cero estructural del componente especializado).

---

## 8. Bitácora (añadir al README §8)

| Fecha | Decisión | Razón |
|---|---|---|
| 2026-06-10 | **Fase 3 cerrada** (ver `FASE_3_PANEL.md`): panel y cobertura/subregistro por tipo | Separa cero estructural de subregistro; base maestra DEIS cruzada |
| 2026-06-10 | **Cruce REM ↔ maestro = 100 %** con código vigente (`cod_estab`) | Panel sólido; ningún establecimiento sin atributos |
| 2026-06-10 | **Subregistro temporal solo aplica a Serie P (stock)**; en A/BS de evento se usa cobertura + intensidad | El denominador de 12 meses sobrestima la expectativa en series de evento |
| 2026-06-10 | **Numerador rector confiable**: P6222300 en CESFAM con 5 % de subregistro (80 % del volumen); subregistro real concentrado en postas rurales (23 %) | El subregistro rural infla la brecha estimada → declarar como caveat territorial |
| 2026-06-10 | Dispositivos PND visibles en el dato (Centros de Apoyo Comunitario; Unidades de Memoria en hospitales terciarios) | Insumo del overlay territorial del programa especializado |
| 2026-06-10 | Rehabilitación cognitiva (`28021500`) es **hospitalaria** e intensiva (intensidad 514) | Bloque aparte; no mezclar con la lógica de APS |
