# mod_metodo.R · Metodologia, caveats y fuentes (estatico)
mod_metodo_ui <- function(id) {
  ns <- NS(id)
  card(
    card_header("Metodología y advertencias"),
    h5("Cómo se calcula el puntaje de prioridad"),
    tags$ul(
      tags$li(strong("Déficit de registro: "), "efecto aleatorio del establecimiento en el modelo multinivel (cuánto registra de menos respecto de lo esperado para su comuna y región). Aísla el componente institucional, que es el intervenible."),
      tags$li(strong("Volumen: "), "inscritos FONASA 60+ del centro. Un déficit en un centro grande afecta a más personas."),
      tags$li(strong("Realce rural (opcional): "), "pondera lo rural, donde el subregistro y la prevalencia esperada son mayores."),
      tags$li("Puntaje = déficit normalizado × volumen normalizado × realce; prioridad por terciles.")
    ),
    h5("Qué NO dice"),
    tags$ul(
      tags$li("Mide ", strong("registro administrativo"), ", no calidad clínica: un centro puede atender bien y registrar mal."),
      tags$li("La brecha mide la visibilidad del subsistema de salud mental, no toda la demencia atendida."),
      tags$li("Las tasas con menos de 5 personas se omiten (resguardo de celdas pequeñas / reidentificación)."),
      tags$li("El denominador de prevalencia tiene incertidumbre (ver triangulación); la brecha se reporta con intervalo.")
    ),
    h5("Fuentes y reproducibilidad"),
    p("Series REM 2025 (DEIS-MINSAL), proyecciones INE, inscritos FONASA, maestro de establecimientos (datos.gob.cl). ",
      "Detalle en ", tags$code("FUNDAMENTACION_ESTADISTICA.pdf"), ", ", tags$code("estado_del_arte.md"),
      " y ", tags$code("diseno_app.md"), ". La app consume ", tags$code("productos/ranking_establecimientos.csv"),
      ", generado por ", tags$code("R/12_ranking_establecimientos.R"), ".")
  )
}
