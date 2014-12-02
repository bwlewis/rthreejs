#' globe.js Three.js globe example.
#'
#' Three.js example that maps points onto the earth.
#'
#' @param img Either a matrix or raster image representation or a character string indicating a file path.
#' @param imwidth Image width.
#' @param imheight Image height.
#' @param lat Data point latitudes (negative values indicate south, positive north).
#' @param long Data point longitudes, must be of same length as \code{lat} (negative values indicate west, positive east).
#' @param value Either a single value indicating the height of all data points, or a vector of values of length x.lat indicating height of each point.
#' @param color Either a single color value indicating the color of all data points, or a vector of values of length x.lat indicating color of each point.
#' @param width The container div width.
#' @param height The container div height.
#'
#' @note
#' The \code{img} argument may be a relative file location string pointing to
#' an image file in shiny applications (see the examples below). The \code{img}
#' argument must be a matrix or raster image representation for non-shiny
#' file-based use. The shiny method can be *much* faster. This limitation comes
#' from the way Three.js loads image textures.
#'
#' @references
#' The threejs project \url{http://threejs.org}.
#' The corresponding javascript file in
#' \code{ system.file("htmlwidgets/globe.js",package="threejs")}.
#'
#' Includes ideas and images from the dat.globe Javascript WebGL Globe Toolkit
#' \url{http://dataarts.github.com/dat.globe},
#' Copyright 2011 Data Arts Team, Google Creative Lab
#' Licensed under the Apache License, Version 2.0
#' \url{http://www.apache.org/licenses/LICENSE-2.0}
#' 
#' @examples
#' ## dontrun
#' # Stand-alone examples:
#' library("threejs")
#'
#' # A shiny example:
#' runApp(system.file("examples/globe",package="threejs"))

#' 
#' @importFrom rjson toJSON
#' @importFrom png readPNG
#' @importFrom jpeg readJPEG
#' @import maps
#' @export
globe.js <- function(
  img=readJPEG(system.file("images/world.jpg",package="threejs")),
  lat,
  long,
  color="red", value=40,
  height = NULL,
  width = NULL)
{
  # create widget
  if(typeof(img)=="character")
  {
    d = c(0,0)
    img = sprintf("\"%s\"",img)
  } else
  {
    d = 2^ceiling(log(dim(img),2))
    img = texture(img)
  }
  htmlwidgets::createWidget(
      name = "globe",
      x = list(img=img, imwidth=d[1], imheight=d[2],
               lat=lat, long=long, color=color, value=value),
               width = width,
               height = height,
               htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
               package = "threejs")
}

#' @rdname threejs-shiny
#' @export
globeOutput <- function(outputId, width = "100%", height = "500px") {
    shinyWidgetOutput(outputId, "globe", width, height,
                        package = "threejs")
}

#' @rdname threejs-shiny
#' @export
renderGlobe <- function(expr, env = parent.frame(), quoted = FALSE) {
    if (!quoted) { expr <- substitute(expr) } # force quoted
    shinyRenderWidget(expr, globeOutput, env, quoted = TRUE)
}
