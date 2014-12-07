#' globe.js Three.js globe widget
#'
#' Three.js widget for mapping points and an image on a globe. The globe can
#' be rotated and and zoomed.
#'
#' @param img A character string representing an image file path
#' of an image to plot on the globe, or or a dataURI image prepared by the \code{texture}
#' function.
#' @param lat Data point latitudes (negative values indicate south, positive north).
#' @param long Data point longitudes, must be of same length as \code{lat} (negative values indicate west, positive east).
#' @param value Either a single value indicating the height of all data points, or a vector of values of length x.lat indicating height of each point.
#' @param color Either a single color value indicating the color of all data points, or a vector of values of length x.lat indicating color of each point.
#' @param bodycolor The diffuse reflective color of the globe object.
#' @param emissive The emissive color of the globe object.
#' @param lightcolor The color of the ambient light in the scene.
#' @param width The container div width.
#' @param height The container div height.
#'
#' @note
#' The \code{img} argument may be a relative file location string pointing to
#' an image file in shiny applications (see the examples below). For non-shiny
#' use, prepare the image file as a dataURI with the \code{texture} function
#' (see the examples).
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
#' Image reference \url{http://www.vendian.org/mncharity/dir3/planet_globes/}.
#'
#' Moon image: \url{http://maps.jpl.nasa.gov/textures/ear1ccc2.jpg}.
#'
#' Mars image: \url{http://pdsmaps.wr.usgs.gov/PDS/public/explorer/html/marsadvc.htm}.
#'
#' Jupiter image: \url{http://maps.jpl.nasa.gov/textures/jup0vtt2.jpg}.
#' 
#' @examples
#' ## dontrun
#' # A shiny example:
#' library("shiny")
#' runApp(system.file("examples/globe",package="threejs"))
#' 
#' # A Stand-alone example:
#' library("threejs")
#' library("maps")
#' data(world.cities, package="maps")
#' cities <- world.cities[order(world.cities$pop,decreasing=TRUE)[1:1000],]
#' value  <- 100 * cities$pop / max(cities$pop)
#' 
#' # Set up a color map, noting that THREE.Color only accepts RGB form
#' # so we need to drop the A value from the colors:
#' col <- sapply(heat.colors(10), function(x) substr(x,1,7))
#' names(col) <- c()
#' col <- col[floor(length(col)*(100-value)/100) + 1]
#'
#' # Load the map of the world as a dataURI image using the \code{texture}
#' # function. This is required for non-shiny use (shiny apps can just use
#' # the file name directly).
#' picture <- texture(system.file("htmlwidgets/lib/globe/world.jpg",package="threejs"))
#' globe.js(img=picture, lat=cities$lat, long=cities$long, value=value, color=col)
#'
#' # Plot them on the moon
#' picture <- texture(system.file("htmlwidgets/lib/globe/moon.jpg",package="threejs"))
#' globe.js(img=picture, bodycolor="#555555", emissive="#444444",
#'          lightcolor="#555555", lat=cities$lat, long=cities$long,
#'          value=value, color=col)
#'
#' @importFrom rjson toJSON
#' @import maps
#' @export
globe.js <- function(
  img, lat, long,
  color="red", value=40,
  bodycolor="#0000ff",emissive="#0000ff",lightcolor="#9999ff",
  height = NULL,
  width = NULL)
{
  options = list(lat=lat, long=long, color=color, value=value,
                 bodycolor=bodycolor, emissive=emissive, lightcolor=lightcolor)
  if(is.list(img))
  {
    x = c(img, options)
  } else
  {
    x = c(options, img=img)
  }
  htmlwidgets::createWidget(
      name = "globe",
      x = x,
      width = width,
      height = height,
      htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
      package = "threejs")
}

#' @rdname threejs-shiny
#' @export
globeOutput <- function(outputId, width = "100%", height = "600px") {
    shinyWidgetOutput(outputId, "globe", width, height,
                        package = "threejs")
}

#' @rdname threejs-shiny
#' @export
renderGlobe <- function(expr, env = parent.frame(), quoted = FALSE) {
    if (!quoted) { expr <- substitute(expr) } # force quoted
    shinyRenderWidget(expr, globeOutput, env, quoted = TRUE)
}
