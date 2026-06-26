# mod_territorio.R · Mapa de centros por volumen bajo control (contexto)
mod_territorio_ui <- function(id) {
  ns <- NS(id)
  tagList(
    if (HAS_LEAFLET) card(card_header("Centros con demencia bajo control (volumen)"),
                          leafletOutput(ns("mapa"), height = 420))
    else card(card_header("Mapa"),
              p("Instala el paquete leaflet para ver el mapa: install.packages('leaflet').")),
    div(class = "text-muted", style = "font-size: 12px;",
        "El tamaño refleja volumen bajo control, no calidad. Centros con <5 personas no muestran tasa (resguardo de celdas pequeñas).")
  )
}

mod_territorio_server <- function(id, rk_ss) {
  moduleServer(id, function(input, output, session) {
    output$mapa <- if (HAS_LEAFLET) renderLeaflet({
      d <- rk_ss(); req(d)
      d <- d[!is.na(lat) & !is.na(lon) & bajo_control_65 > 0]
      req(nrow(d) > 0)
      leaflet(d) |> addProviderTiles(providers$CartoDB.Positron) |>
        addCircleMarkers(~lon, ~lat,
                         radius = ~pmin(3 + sqrt(bajo_control_65), 18),
                         stroke = TRUE, weight = 0.4, color = "#5b6770",
                         fillColor = "#534AB7", fillOpacity = 0.6,
                         popup = ~sprintf("<b>%s</b><br>%s<br>Bajo control 65+: %s",
                                          nombre, comuna, bajo_control_65)) |>
        setView(lng = -72, lat = -39, zoom = 4)
    })
  })
}
