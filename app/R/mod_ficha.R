# mod_ficha.R · Drill de un establecimiento y comparacion con sus pares
mod_ficha_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("centro"), "Establecimiento", choices = NULL, width = "100%"),
    layout_columns(
      col_widths = c(6, 6),
      card(card_header("Ficha del establecimiento"), tableOutput(ns("ficha"))),
      card(card_header("Comparación con pares (mismo tipo y zona)"),
           tableOutput(ns("pares")))
    ),
    div(class = "text-muted", style = "font-size: 12px;",
        "Pares = establecimientos del mismo tipo y zona. Déficit alto = registra menos de lo esperado para su contexto.")
  )
}

mod_ficha_server <- function(id, rk_ss) {
  moduleServer(id, function(input, output, session) {
    observe({
      d <- rk_ss(); req(d)
      ch <- d[order(-score), setNames(cod_estab, paste0(nombre, " — ", comuna))]
      updateSelectInput(session, "centro", choices = ch)
    })
    sel <- reactive({ d <- rk_ss(); req(d, input$centro); d[cod_estab == input$centro][1] })

    output$ficha <- renderTable({
      s <- sel(); req(nrow(s) == 1)
      data.table(Campo = c("Nombre","Comuna","Servicio de Salud","Tipo","Zona",
                           "Inscritos 60+","Bajo control 65+","Detección",
                           "Déficit de registro","Puntaje","Prioridad"),
                 Valor = c(s$nombre, s$comuna, s$servicio_salud, s$tipo, s$zona,
                           mil(s$inscritos_60), mil(s$bajo_control_65),
                           pct(s$deteccion), formatC(s$deficit, format="f", digits=2),
                           as.character(s$score), s$prioridad))
    })

    output$pares <- renderTable({
      s <- sel(); d <- rk_ss(); req(nrow(s) == 1)
      p <- d[tipo == s$tipo & zona == s$zona]
      data.table(Indicador = c("Centros comparables","Déficit del centro",
                               "Déficit mediano de pares","Puntaje del centro",
                               "Puntaje mediano de pares"),
                 Valor = c(mil(nrow(p)),
                           formatC(s$deficit, format="f", digits=2),
                           formatC(median(p$deficit, na.rm=TRUE), format="f", digits=2),
                           as.character(s$score),
                           as.character(round(median(p$score, na.rm=TRUE), 1))))
    })
  })
}
