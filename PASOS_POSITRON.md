# Runbook Positron — aplicar las mejoras (ronda 2026-06-25)

Las mejoras de archivos ya están escritas. Aquí van las líneas que tú corres en Positron.
**Consola** = consola de R (abajo). **Terminal** = pestaña Terminal (shell del sistema).
Corre en orden. Cada bloque dice dónde va.

---

## 0. PC recién formateado: instalar todo (una vez)

**Fuera de R** (instaladores): instala **R** (≥ 4.2) y **Quarto CLI** (https://quarto.org/docs/get-started/). Positron ya trae el editor; apunta su intérprete de R al que instalaste.

**Consola** — instala todos los paquetes del flujo de una pasada:

```r
source("R/_paquetes.R")
```

O, equivalente, en una línea:

```r
install.packages(c("here","data.table","stringr","readxl","glmmTMB","sf","spdep",
  "chilemapas","leaflet","leaflet.extras","ggplot2","scales","DT","knitr",
  "rmarkdown","quarto"), repos = "https://cloud.r-project.org")
```

En Windows no necesitas Rtools ni librerías de sistema: `sf`/`spdep` se instalan como binarios desde CRAN. La descarga total es de varios cientos de MB; puede tardar unos minutos.

**Excepción `chilemapas`** (en R 4.6.0 aún no hay binario; es solo datos/R, no requiere Rtools):

- Sin renv activo: `install.packages("chilemapas", type = "source")`
- **Con renv activo** (renv no resuelve la fuente de CRAN) instálalo desde GitHub:

```r
renv::install("pachadotdev/chilemapas")
# si falla:  install.packages("pak"); pak::pkg_install("pachadotdev/chilemapas")
requireNamespace("chilemapas")   # TRUE
```

> Si vas a usar `renv` (Paso 1), puedes saltarte este paso e instalar dentro del proyecto: `renv::init()` detecta estos mismos paquetes desde el código y los instala en la librería del proyecto.

---

## 1. Fijar el entorno reproducible (A4)

No pegues las tres líneas juntas: `renv::init()` pide **reiniciar R** antes de `snapshot()`.

**Consola** (una a una):

```r
install.packages("renv")
renv::init()   # responde "y"; crea renv.lock y activa el proyecto
```

Reinicia R (paleta de Positron → "R: Restart R Session"). Tras el reinicio, asegura `chilemapas` en la librería del proyecto y recién ahí haz el snapshot:

```r
if (!requireNamespace("chilemapas", quietly = TRUE)) install.packages("chilemapas", type = "source")
renv::snapshot()   # responde "y"
```

> Si `renv::snapshot()` te muestra un menú "1/2/3" porque aún no reiniciaste, elige **3** (cancelar), reinicia R y vuelve a correr `renv::snapshot()`.

**Terminal:**

```bash
git add renv.lock .Rprofile renv/activate.R
git commit -m "Fijar entorno reproducible con renv"
```

---

## 2. Correr el pipeline completo (ya falla ruidosamente)

**Consola:**

```r
source("R/10_run_all.R")
```

Si algún script falla, ahora termina con error y lista cuáles (antes seguía en silencio).
Esto regenera `productos/`, incluido el nuevo `productos/sensibilidad_prevalencia.csv`.

---

## 3. Ver la triangulación de prevalencia (A1)

**Consola:**

```r
data.table::fread("productos/sensibilidad_prevalencia.csv")
```

Lee `brecha_pais` bajo `10_66_raw` vs `10_66_suave` y el intervalo `brecha_lo95`–`brecha_hi95`.
Si la brecha se mueve poco y el intervalo es estrecho, la conclusión es robusta al denominador.

### 3b. Añadir la curva externa GBD (recomendado)

1. Entra a GHDx/IHME (https://ghdx.healthdata.org/gbd-2021) y obtén la prevalencia de demencia por edad para **Chile** (proporción 0..1) por banda 60-64 … 85+.
2. Crea `datos/externos/prevalencia_externa.csv` con columnas exactas:

```
banda,prev_total,prev_urbano,prev_rural
60-64,...,...,...
65-69,...,...,...
70-74,...,...,...
75-79,...,...,...
80-84,...,...,...
85+,...,...,...
```

(Si GBD no separa urbano/rural, repite el valor total en las tres columnas.)

3. Vuelve a correr y compara los tres escenarios. Para usar el intervalo real de GBD en vez del CV supuesto, ajusta `REM_CV_PREV` antes de sourcear:

**Consola:**

```r
Sys.setenv(REM_CV_PREV = "0.15")   # reemplaza por el CV implícito del IC de GBD
source("R/11_sensibilidad_prevalencia.R")
data.table::fread("productos/sensibilidad_prevalencia.csv")
```

---

## 4. Render del dashboard (cifras ahora se leen del pipeline, A6)

**Terminal:**

```bash
quarto render
```

Revisa que `deteccion.html` muestre la brecha y los esperados desde `productos/` (ya no a mano).

---

## 5. Commit de toda la ronda (A8)

**Terminal:**

```bash
git add -A
git commit -m "Auditoria 2026-06: estado del arte, triangulacion de prevalencia, caveats de celdas pequenas, pipeline robusto, licencias y CITATION"
```

---

## Pendientes que requieren tu decisión (dímelo y los hago)

- **Mapa territorial (A2):** `territorio.qmd` aún colorea todas las comunas; conviene que el mapa y la tabla usen `tasa_deteccion_pub` / `brecha_pub` (enmascaradas) en vez de las crudas, para no mostrar celdas de 0-1 persona. Puedo editar `territorio.qmd`.
- **Informe técnico (A7):** `articulo.qmd` es un esqueleto. O lo completo leyendo de `productos/`, o lo retiramos del alcance (la fundamentación ya cumple ese rol).
- **Curva de prevalencia primaria (A1):** tras ver la triangulación, decidir si la cifra principal pasa a la curva suavizada o a GBD, y si se mantiene el ajuste rural (confundido con escolaridad) o se modela.
- **DOI / archivo abierto (A9):** depositar una versión en Zenodo/OSF cuando quieras una cita permanente.
