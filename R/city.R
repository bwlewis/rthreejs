
#' @export
cityjs <- function(
  value=40,
  color="#00ffff",
  atmosphere=FALSE,
  bg="black",
  height = NULL,
  width = NULL, ...)
{
  
  options <- list(color=color, value=value, atmosphere=atmosphere, bg=bg)
  additional_args <- list(...)
  if(length(additional_args) > 0) options <- c(options, additional_args)
  
  x <- c(options)
  
  htmlwidgets::createWidget(
    name = "city",
    x = x,
    width = width,
    height = height,
    htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
    package = "threejs")
}

#' @rdname threejs-shiny
#' @export
cityOutput <- function(outputId, width = "100%", height = "600px") {
  
    shinyWidgetOutput(outputId, "city", width, height,
                        package = "threejs")
}

#' @rdname threejs-shiny
#' @export
renderCity <- function(expr, env = parent.frame(), quoted = FALSE) {
  
    if (!quoted) {
      expr <- substitute(expr)
    } # force quoted
    shinyRenderWidget(expr, cityOutput, env, quoted = TRUE)
}
