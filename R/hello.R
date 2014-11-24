#' helloThree.js  Three.js hello world example.
#'
#' Three.js hello world example, maps an image onto a rotating sphere.
#'
#' @param img Either a matrix or raster image representation.
#' @param repeatX The number of times to repeat the image along the X axis.
#' @param repeatY The number of times to repeat the image along the Y axis.
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
#' helloThree.js(readPNG(system.file("img/Rlogo.png",package="png")))
#' helloThree.js(readJPEG(system.file("images/moon_1024.jpg",package="threejs")))
#'
#' # A shiny example:
#' runApp(system.file("examples/hello",package="threejs"), launch.browser=FALSE)

#' 
#' @importFrom rjson toJSON
#' @importFrom png readPNG
#' @importFrom jpeg readJPEG
#' @export
helloThree.js <- function(
  img=readPNG(system.file("img/Rlogo.png",package="png")),
  repeatX=8, repeatY=8,
  ambient="#999", specular="#ffa", shininess=10,
  height = NULL,
  width = NULL)
{
  # create widget
  d = 2^ceiling(log(dim(img),2))
  htmlwidgets::createWidget(
      name = "hello",
      x = list(data=texture(img), texwidth=d[1], texheight=d[2],
               repeatX=repeatX, repeatY=repeatY,
               ambient=ambient, specular=specular, shininess=shininess),
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

