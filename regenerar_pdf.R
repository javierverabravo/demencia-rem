# =============================================================================
# regenerar_pdf.R  ·  Regenera FUNDAMENTACION_ESTADISTICA.pdf desde el .md
# -----------------------------------------------------------------------------
# Uso:  en Positron, con el proyecto abierto:   source("regenerar_pdf.R")
#
# Usa el pandoc que YA trae Quarto (no necesitas instalar pandoc aparte).
# Requisito, UNA SOLA VEZ: un motor LaTeX. Si el script falla diciendo que falta
# xelatex/LaTeX, abre la pestaña Terminal y ejecuta:   quarto install tinytex
# (instala TinyTeX, ~1 min; después este script funciona siempre).
# =============================================================================

md_in  <- "FUNDAMENTACION_ESTADISTICA.md"
pdf_out <- "FUNDAMENTACION_ESTADISTICA.pdf"
stopifnot(file.exists(md_in))

# El .md empieza con un # H1 que queremos usar como TÍTULO (no como sección):
# lo quitamos del cuerpo y lo pasamos como metadato.
md <- readLines(md_in, encoding = "UTF-8", warn = FALSE)
tmp <- tempfile(fileext = ".md")
writeLines(md[-1], tmp, useBytes = TRUE)   # cuerpo sin la primera línea

args <- c(
  "pandoc", shQuote(tmp), "-o", shQuote(pdf_out),
  "--pdf-engine=xelatex", "--toc", "--toc-depth=2",
  "-V", "geometry:margin=2.3cm", "-V", "fontsize=11pt", "-V", "lang=es",
  "-V", "colorlinks=true", "-V", "linkcolor=RoyalBlue",
  "-V", shQuote("title=Fundamentación estadística — explicada para todo público"),
  "-V", shQuote("subtitle=Brecha de detección de demencia en la red pública · Series REM Chile"),
  "-V", shQuote("date=Junio 2026")
)

status <- tryCatch(system2("quarto", args), error = function(e) 1L)

if (identical(status, 0L) && file.exists(pdf_out)) {
  message("✓ PDF regenerado: ", normalizePath(pdf_out))
  message("  Recuerda: para publicarlo, corre  quarto publish gh-pages  y luego git add/commit/push.")
} else {
  message("✗ No se pudo generar el PDF.")
  message("  Causa más probable: falta el motor LaTeX. En la Terminal ejecuta una vez:")
  message("      quarto install tinytex")
  message("  y vuelve a correr  source(\"regenerar_pdf.R\").")
}
unlink(tmp)
