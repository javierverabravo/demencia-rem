# mod_priorizacion.R · Vista principal: ranking de centros a intervenir
mod_priorizacion_ui <- function(id) {
  ns <- NS(id)
  tagList(
    layout_columns(
      col_widths = c(4, 4, 4),
      value_box("Centros en vista", textOutput(ns("n_centros")), theme = "secondary"),
      value_box("Prioridad alta", textOutput(ns("n_alta")), theme = "danger"),
      value_box("Personas bajo control", textOutput(ns("n_bc")), theme = "secondary")
    ),
    layout_columns(
      col_widths = c(3, 3, 3, 3),
      selectInput(ns("comuna"), "Comuna", choices = "Todas"),
      selectInput(ns("tipo"), "Tipo", choices = "Todos"),
      selectInput(ns("zona"), "Zona", choices = c("Todas","urbano","mixto","rural")),
      div(style = "margin-top: 28px;",
          downloadButton(ns("dl"), "Exportar CSV", class = "btn-sm"))
    ),
    if (HAS_LEAFLET) card(card_header("Mapa de centros (color = prioridad)"),
                          leafletOutput(ns("mapa"), height = 320)),
    card(card_header("Establecimientos priorizados"),
         DTOutput(ns("tabla"))),
    div(class = "text-muted", style = "font-size: 12px; margin-top: 6px;",
        "El deficit mide registro administrativo ajustado por contexto, no calidad clinica.")
  )
}

mod_priorizacion_server <- function(id, rk_ss) {
  moduleServer(id, function(input, output, session) {
    observe({
      d <- rk_ss(); req(d)
      updateSelectInput(session, "comuna", choices = c("Todas", sort(unique(d$comuna))))
      updateSelectInput(session, "tipo",   choices = c("Todos", sort(unique(d$tipo))))
    })

    filt <- reactive({
      d <- rk_ss(); req(d)
      if (input$comuna != "Todas") d <- d[comuna == input$comuna]
      if (input$tipo   != "Todos") d <- d[tipo == input$tipo]
      if (input$zona   != "Todas") d <- d[zona == input$zona]
      d
    })

    output$n_centros <- renderText(mil(nrow(filt())))
    output$n_alta    <- renderText(mil(filt()[prioridad == "Alta", .N]))
    output$n_bc      <- renderText(mil(filt()[, sum(bajo_control_65, na.rm = TRUE)]))

    output$tabla <- renderDT({
      d <- filt()[, .(Establecimiento = nombre, Comuna = comuna, Tipo = tipo,
                      Zona = zona, `Inscritos 60+` = inscritos_60,
                      `Deficit` = deficit, `Bajo control` = bajo_control_65,
                      `Detección %` = round(100 * deteccion, 1),
                      Puntaje = score, Prioridad = prioridad)]
      datatable(d, rownames = FALSE, filter = "top",
                options = list(pageLength = 12, order = list(list(8, "desc")),
                               scrollX = TRUE)) |>
        formatStyle("Prioridad", backgroundColor = styleEqual(
          names(COL_PRIO), paste0(COL_PRIO, "22")),
          fontWeight = "500")
    })

    output$mapa <- if (HAS_LEAFLET) renderLeaflet({
      d <- filt()[!is.na(lat) & !is.na(lon)]
      req(nrow(d) > 0)
      pal <- COL_PRIO[d$prioridad]; pal[is.na(pal)] <- "#888780"
      leaflet(d) |> addProviderTiles(providers$CartoDB.Positron) |>
        addCircleMarkers(~lon, ~lat, radius = 5, stroke = TRUE, weight = 0.5,
                         color = "#5b6770", fillColor = pal, fillOpacity = 0.85,
                         popup = ~sprintf("<b>%s</b><br>%s · %s<br>Puntaje: %s · %s",
                                          nombre, comuna, tipo, score, prioridad)) |>
        setView(lng = -72, lat = -39, zoom = 4)
    })

    output$dl <- downloadHandler(
      filename = function() "ranking_priorizacion.csv",
      content = function(file) fwrite(filt(), file)
    )
  })
}
