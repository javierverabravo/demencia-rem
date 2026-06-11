# Fase 2 · Crosswalks — prestaciones y columnas

> Entregable de la Fase 2 (junio 2026). Cura los dos crosswalks que definen el universo del análisis y el significado de cada columna: `crosswalk/crosswalk_demencia_prestaciones.csv` (código → bloque) y `crosswalk/crosswalk_demencia_columnas.csv` (sección × `Col01…Col50` → qué mide). Resuelve los pendientes que dejaron las Fases 0-1: aislar el numerador 65+ de la pregunta rectora, ubicar las marginales pueblos originarios/migrantes y la duplicidad `P6222300` vs `P6223310`.
>
> **Método:** lectura programática de los diccionarios `.xlsm` (una hoja por formulario). En cada hoja, la fila del código trae marcadores `COL01…COLnn` que mapean columna de planilla → posición `Col` del CSV; las filas-encabezado de la sección (rango etario, sexo, grupos marginales) definen el significado de cada columna. Mapeo con *forward-fill* de las celdas combinadas y verificación contra los datos reales.

---

## 1. Resultado central: estructura de columnas por bloque

Los bloques con **desagregación etaria × sexo** comparten un layout idéntico y verificado:

| `Col` | Significado |
|---|---|
| Col01 / Col02 / Col03 | TOTAL: ambos sexos / hombres / mujeres |
| Col04 … Col37 | 17 bandas etarias (0-4, 5-9, …, 75-79, 80 y más) × (Hombres, Mujeres) |
| **Col30 … Col37** | **65+ = (65-69, 70-74, 75-79, 80 y más) × (H, M) → el numerador etario de la rectora** |

Bloques que siguen este layout: **P6 A.1 (APS)**, **P6 B.1 (Especialidad)**, **P3**, **A05 ingresos**, **A05 egresos**. En todos, 65+ = `Col30:Col37`.

### Marginales de equidad (pueblos originarios / migrantes), por bloque

| Bloque | Pueblos Originarios | Migrantes | Desagregación |
|---|---|---|---|
| P6 A.1 / B.1 | Col40 (H), Col41 (M) | Col42 (H), Col43 (M) | por sexo |
| P3 | Col39 (H), Col40 (M) | Col41 (H), Col42 (M) | por sexo |
| A05 ingresos / egresos | Col41 | Col42 | columna única |
| A26 | Col10 | Col09 | columna única (por tipo de visita) |

> **Ojo:** la posición de las marginales **cambia entre bloques** (P6 vs P3 vs A05). El crosswalk de columnas guarda la posición correcta por sección; no asumir una posición única.

### Bloques sin desagregación etaria estándar

- **A06 Secc. F (PND, `06906135/140/145`)**: columnas por **número de profesionales** (1/2/3), ~4 columnas. Sin edad ni equidad → solo conteo de evaluaciones (insumo de Q4 cuidadores, exploratoria).
- **A26 (`264110xx`)**: 12 columnas por **tipo de visita** domiciliaria + marginales Migrantes (Col09) y Pueblos Originarios (Col10). Sin banda etaria.
- **A19a (`19201021`)**: 2 columnas (Total Actividades, Espacios Amigables).
- **BS · B (`01010053/54/916`)** y **A28 (`28201001`…)**: prestaciones con ~38-41 columnas de tramos/actividades, sin la grilla etaria estándar → se usan como **volumen** del bloque rehabilitación/cognitivo, no para aislar 65+.

---

## 2. Duplicidad `P6222300` vs `P6223310` — RESUELTA

No se duplican: son **dos niveles de atención del mismo diagnóstico** "Demencias (incluye Alzheimer)".

- `P6222300` → **SECCIÓN A.1: Población en control en APS** (atención primaria). El grueso: 1.224 establecimientos.
- `P6223310` → **SECCIÓN B.1: Población en control en Especialidad**. Menor: 110 establecimientos.

Ambas comparten el mismo layout de columnas (65+ = Col30:Col37). **Regla:** el numerador total de población bajo control por demencia = `P6222300` (APS) **+** `P6223310` (Especialidad); se pueden sumar por columna sin doble conteo (son redes distintas), o analizar por separado por nivel. La pregunta rectora se ancla en APS, con Especialidad como complemento.

---

## 3. Validación contra los datos reales (Serie P 2025)

Reconstrucción de totales por código (suma anual de celdas; los dos cortes semestrales):

| Código | Total (Col01) | H+M (Col02+03) | Σ bandas etarias (Col04-37) | 65+ (Col30-37) | % 65+ |
|---|---:|---:|---:|---:|---:|
| P6222300 (APS) | 25.890 | 25.890 ✓ | 25.890 ✓ | 23.816 | 92,0 |
| P6223310 (Esp.) | 2.885 | 2.885 ✓ | 2.885 ✓ | 2.022 | 70,1 |
| P3171613 | 45.366 | 45.366 ✓ | 45.364 (dif 2) | 44.036 | 97,1 |

Cumple los tres criterios de validación de la skill `rem-datos`: (a) total = hombres + mujeres exacto; (b) total ≈ suma de columnas desagregadas (P3 difiere en 2 de 45.366 = 99,996%); (c) las columnas mapeadas existen en el CSV. El alto **% 65+** (92-97%) confirma que la demencia bajo control es casi enteramente de personas mayores → usar 65+ como numerador es correcto y pierde muy poco.

---

## 4. Archivos entregados

- `crosswalk/crosswalk_demencia_prestaciones.csv` — 24 códigos → serie/formulario/bloque (Fase 0-1).
- `crosswalk/crosswalk_demencia_columnas.csv` — 254 filas: sección × `Col` → etiqueta, dimensión, grupo etario, sexo, flag `es_65mas`, flag `equidad`. 40 columnas marcadas 65+; 18 marginales de equidad (9 PO + 9 migrantes).
- `R/utils_columnas.R` — helper que aplica el crosswalk: `agregar_demencia_etario()` (deriva total, 65+, sexo, PO, migrantes) y `validar_columnas()`. Lo usará el motor en Fase 5.

---

## 5. Pendientes para Fase 3-5

- **A06 controles (marginal "Demencia" / "sospecha de demencia")**: la información de demencia del A06 fuera de la Secc. F vive en columnas marginales de secciones de SM más amplias (consultorías `06300100`, teleconsultorías `06907017`). Para la cascada (Q2) habrá que fijar esas columnas marginales en su sección; quedó identificada la mecánica, falta la posición exacta (prioridad media, Q2 es secundaria).
- **A26 "con demencia" por diferencia**: el eje da dependencia severa con/sin demencia; documentar la fórmula `total − sin demencia` en el motor.
- **Caveat migrante**: las marginales de migrantes son columnas únicas y pequeñas (P6 APS: 144 al año); subpotenciadas para demencia 65+ (ya anticipado).
- El numerador comunal 65+ definitivo se arma en Fase 5 sobre el panel (Fase 3), usando `agregar_demencia_etario()` + denominador INE (Fase 4).

---

## 6. Bitácora (añadir al README §8)

| Fecha | Decisión | Razón |
|---|---|---|
| 2026-06-10 | **Fase 2 cerrada**: crosswalks de prestaciones y columnas curados y validados | Define universo y significado de columnas; destraba el numerador 65+ |
| 2026-06-10 | **65+ = Col30:Col37** en P6 (APS+Esp.), P3 y A05 (layout etario idéntico, verificado) | Numerador etario de la rectora; validado contra datos (92-97% del total) |
| 2026-06-10 | **`P6222300` (APS) + `P6223310` (Especialidad) se suman** (no duplican) | Son niveles de atención distintos del mismo diagnóstico; mismo layout de columnas |
| 2026-06-10 | Marginales PO/migrantes mapeadas con posición **distinta por bloque** (P6 Col40-43, P3 Col39-42, A05 Col41-42, A26 Col09-10) | El crosswalk de columnas guarda la posición por sección; no asumir posición única |
| 2026-06-10 | A06 Secc. F sin desagregación etaria (columnas por nº de profesionales) | Confirma su rol menor (Q4 exploratoria); la demencia "de cascada" del A06 está en marginales de controles, pendiente de pinear |
