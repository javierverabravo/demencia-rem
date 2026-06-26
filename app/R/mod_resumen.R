# mod_resumen.R · Mensaje principal: brecha pais y del Servicio seleccionado
mod_resumen_ui <- function(id) {
  ns <- NS(id)
  tagList(
    layout_columns(
      col_widths = c(4, 4, 4),
      value_box("Brecha país", textOutput(ns("brecha_pais")),
                p(textOutput(ns("ic_pais"), inline = TRUE), class = "small"),
                theme = "danger"),
      value_box("Servicio seleccionado", textOutput(ns("ss_nom")),
                p(textOutput(ns("ss_centros"), inline = TRUE), class = "small"),
                theme = "secondary"),
      value_box("Centros prioritarios", textOutput(ns("ss_prio")),
                theme = "warning")
    ),
    card(
      card_header("Cómo leer esta herramienta"),
      p("La ", strong("brecha de detección"), " compara cuántas personas mayores con demencia ",
        "están bajo control en la red pública frente a cuántas se esperan por prevalencia. ",
        "El análisis muestra que la variación depende sobre todo del ", strong("establecimiento"),
        " (53% de la varianza, MOR ≈ 16): por eso la palanca es ", strong("centro a centro"),
        ", coordinada por Servicio de Salud."),
      p(class = "text-muted", style = "font-size: 13px;",
        "Mide visibilidad del subsistema de salud mental, no demencia total ni calidad clínica. ",
        "Las tasas por Servicio son indicativas (nivel de centro).")
    )
  )
}

mod_resumen_server <- function(id, rk_ss, ss_sel) {
  moduleServer(id, function(input, output, session) {
    output$brecha_pais <- renderText(pct(brecha_pais, 1))
    output$ic_pais <- renderText({
      if (any(is.na(ic_pais))) "" else paste0("IC95 ", pct(ic_pais[1]), "–", pct(ic_pais[2]))
    })
    output$ss_nom <- renderText(ss_sel())
    output$ss_centros <- renderText({
      d <- rk_ss(); req(d)
      paste0(mil(nrow(d)), " centros · ", mil(sum(d$bajo_control_65, na.rm = TRUE)), " bajo control")
    })
    output$ss_prio <- renderText({
      d <- rk_ss(); req(d); mil(d[prioridad %in% c("Alta","Media"), .N])
    })
  })
}
