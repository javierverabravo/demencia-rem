# =============================================================================
# app.R · App de priorizacion de establecimientos (prototipo)
# -----------------------------------------------------------------------------
# Audiencia: gestores de Servicios de Salud / MINSAL. Tarea: decidir que centros
# intervenir primero para cerrar la brecha de deteccion de demencia.
# global.R y los modulos en R/ se auto-cargan por Shiny. Correr desde la raiz:
#   shiny::runApp("app")
# =============================================================================

# Carga explicita de datos y modulos (no depende del auto-source de Shiny).
if (!exists("RANK")) source("global.R", local = FALSE)

if (is.null(RANK)) {
  ui <- page_fillable(
    card(
      card_header("Falta el insumo de la app"),
      p("La app necesita ", tags$code("productos/ranking_establecimientos.csv"),
        ". Genéralo en la consola de R:"),
      tags$pre('source("R/09_sintesis.R")\nsource("R/12_ranking_establecimientos.R")'),
      p("o corre el pipeline completo: ", tags$code('source("R/10_run_all.R")'), ".")
    )
  )
  server <- function(input, output, session) {}
} else {
  ui <- page_navbar(
    title = "Demencia · priorización de centros",
    theme = bs_theme(version = 5, primary = "#2C5F7C"),
    sidebar = sidebar(
      width = 300,
      selectInput("ss", "Servicio de Salud", choices = SS_CHOICES),
      p(class = "text-muted", style = "font-size: 12px;",
        "Elige un Servicio para filtrar todas las vistas. La palanca del análisis es centro a centro.")
    ),
    nav_panel("Resumen", mod_resumen_ui("res")),
    nav_panel("Priorización", mod_priorizacion_ui("prio")),
    nav_panel("Ficha de centro", mod_ficha_ui("ficha")),
    nav_panel("Territorio", mod_territorio_ui("terr")),
    nav_panel("Metodología", mod_metodo_ui("met"))
  )

  server <- function(input, output, session) {
    rk_ss <- reactive({
      if (is.null(input$ss) || input$ss == "Todos") RANK
      else RANK[servicio_salud == input$ss]
    })
    ss_sel <- reactive(if (is.null(input$ss)) "Todos" else input$ss)

    mod_resumen_server("res", rk_ss, ss_sel)
    mod_priorizacion_server("prio", rk_ss)
    mod_ficha_server("ficha", rk_ss)
    mod_territorio_server("terr", rk_ss)
  }
}

shinyApp(ui, server)
