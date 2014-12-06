#' helloThree.js  Three.js hello world example.
#'
#' Three.js hello world example, maps an image onto a rotating sphere.
#'
#' @param img Either a character string indicating a path to a file
#'        (shiny apps), or an image texture prepared by \code{texture}.
#' @param ambient The intensity/color of object light scattering.
#' @param specular The intensity/color of object specular reflection.
#' @param shininess The shininess of the object.
#' @param width The container div width.
#' @param height The container div height.
#'
#' @references
#' The threejs project \url{http://threejs.org}.
#' The corresponding javascript file in
#' \code{ system.file("htmlwidgets/hello.js",package="threejs")}.
#' 
#' @examples
#' ## dontrun
#' # Stand-alone examples:
#' library("threejs")
#' helloThree.js(texture(system.file("img/Rlogo.jpg",package="threejs")))
#' helloThree.js(texture(system.file("images/moon.jpg",package="threejs")))
#'
#' # A shiny example:
#' library("shiny")
#' runApp(system.file("examples/hello",package="threejs"), launch.browser=FALSE)

#' 
#' @importFrom rjson toJSON
#' @export
helloThree.js <- function(
  img, ambient="#999", specular="#ffa", shininess=10,
  height = NULL, width = NULL)
{
  # create widget
  options=list(ambient=ambient,specular=specular, shininess=shininess)
  if(is.list(img))
  {
    x = c(img,options)
  } else
  {
    x = c(options, img=img)
  }
  htmlwidgets::createWidget(
      name = "hello", toJSON(x),
               width = width,
               height = height,
               htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
               package = "threejs")
}

#' @rdname threejs-shiny
#' @export
helloOutput <- function(outputId, width = "100%", height = "500px") {
    shinyWidgetOutput(outputId, "hello", width, height,
                        package = "threejs")
}

#' @rdname threejs-shiny
#' @export
renderHello <- function(expr, env = parent.frame(), quoted = FALSE) {
    if (!quoted) { expr <- substitute(expr) } # force quoted
    shinyRenderWidget(expr, helloOutput, env, quoted = TRUE)
}

