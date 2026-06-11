# Crosswalks pendientes (Fase 0/2)

Aquí van los dos crosswalks curados a mano, siguiendo la skill `rem-datos`:

1. `crosswalk_demencia_prestaciones.csv` — CodigoPrestacion → serie/formulario/sección/bloque + descripción. Partir de la tabla del README y verificar cada código contra el Manual REM 2025-2026 y el diccionario de su serie.
2. `crosswalk_demencia_columnas.csv` — sección × Col01…Col50 → qué mide (total, sexo, edad, etc.). Ojo: en Serie P las columnas suelen ser grupos de edad — clave para aislar 65+.

Recordatorios:
- Los códigos del formulario pueden no coincidir con el CodigoPrestacion del CSV (verificar en diccionario).
- Validar: totales reconstruidos ≈ columna total; códigos del CSV ausentes del diccionario.
- Versionar estos archivos en git.

---

## Estado (Fase 2 cerrada, 2026-06-10) — ver `FASE_2_CROSSWALKS.md`

- `crosswalk_demencia_prestaciones.csv` — **construido** (24 códigos, Fase 0-1).
- `crosswalk_demencia_columnas.csv` — **construido y validado** (254 filas).
  - Bloques con edad×sexo (P6 A.1/B.1, P3, A05): **65+ = Col30:Col37**.
  - Marginales equidad con posición distinta por bloque (P6 Col40-43, P3 Col39-42, A05 Col41-42, A26 Col09-10).
  - Validación: total = H+M exacto; total ≈ Σ bandas etarias (P3 difiere en 2 de 45.366).
- Aplicación en R: `R/utils_columnas.R` (`agregar_demencia_etario()`, `validar_columnas()`).
- Pendiente: posición exacta de la marginal "Demencia"/"sospecha" en A06 controles (Q2, prioridad media).
