#' globejs Three.js globe widget
#'
#' Three.js widget for mapping points and an image on a globe. The globe can
#' be rotated and and zoomed.
#'
#' @param img A character string representing a file path or URI of an image to plot on the globe surface.
#' @param lat Data point latitudes, must be of same length as \code{long} (negative values indicate south, positive north).
#' @param long Data point longitudes, must be of same length as \code{lat} (negative values indicate west, positive east).
#' @param color Either a single color value indicating the color of all data points, or a vector of values of the same length as \code{lat} indicating color of each point.
#' @param value Either a single value indicating the height of all data points, or a vector of values of the same length as \code{lat} indicating height of each point.
#' @param atmosphere TRUE enables WebGL atmpsphere effect.
#' @param bg Plot background color.
#' @param width The container div width.
#' @param height The container div height.
#' @param ... Additional arguments to pass to the three.js renderer (see
#' below for more information on these options).
#'
#' @note
#' The \code{img} argument specifies the WebGL texture image to wrap on a
#' sphere. If you plan to plot points using \code{lat} and \code{lon}
#' the image should be a plate carrée (aka lat/long) equirectangular
#' map projection; see
#' \url{https://en.wikipedia.org/wiki/Equirectangular_projection} for
#' details..
#' Lat/long maps are commonly found for most planetary bodies in the
#' solar system, and are also easily generated directly in R
#' (see the references and examples below).
#'
#' @section Available rendering options:
#' \itemize{
#'   \item{"bodycolor"}{The diffuse reflective color of the globe.}
#'   \item{"emissive"}{The emissive color of the globe object.}
#'   \item{"lightcolor"}{The color of the ambient light in the scene.}
#'   \item{"fov"}{The initial field of view, default is 35.}
#'   \item{"rotationlat"}{The initial globe latitudinal rotation in radians, default is 0.}
#'   \item{"rotationlong"}{The initial globe longitudinal rotation in radians, default is 0.}
#' }
#' Specify colors with standard color names or hex color representations.
#' The default values (well-suited to many earth-like map images) are
#' \code{lightcolor = "#aa8877"}, \code{emissive = "#0000ff"}, and \code{bodycolor = "#0000ff"}.
#' Larger \code{fov} values result in a smaller (zoomed out) globe.
#' The latitude and longitude rotation values are relative to the center of
#' the map image. Their default values of zero radians result in the front of the
#' globe corresponding to the center of the flat map image.
#'
#' @references
#' The three.js project \url{http://threejs.org}.
#' (The corresponding three.js javascript file is in
#' \code{ system.file("htmlwidgets/globejs",package="threejs")}.)
#'
#' An excellent overview of available map coordinate reference systems (PDF):
#' \url{https://www.nceas.ucsb.edu/~frazier/RSpatialGuides/OverviewCoordinateReferenceSystems.pdf}
#'
#' Includes ideas and images from the dat.globe Javascript WebGL Globe Toolkit
#' \url{http://dataarts.github.com/dat.globe},
#' Copyright 2011 Data Arts Team, Google Creative Lab
#' Licensed under the Apache License, Version 2.0
#' \url{http://www.apache.org/licenses/LICENSE-2.0}
#'
#' NASA Blue Marble/MODIS Earth images \url{visibleearth.nasa.gov}
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
#' # Set up a color map
#' col <- heat.colors(10)
#' col <- col[floor(length(col)*(100-value)/100) + 1]
#'
#' # The name of a jpeg or PNG image file to wrap over the globe:
#' earth <- system.file("images/world.jpg",  package="threejs")
#' globejs(img=earth, lat=cities$lat, long=cities$long, value=value,
#'         color=col, atmosphere=TRUE)
#'
#' # Plot the data on the moon:
#' moon <- system.file("images/moon.jpg", package="threejs")
#' globejs(img=moon, bodycolor="#555555", emissive="#444444",
#'          lightcolor="#555555", lat=cities$lat, long=cities$long,
#'          value=value, color=col)
#'
#' # Plot a high-resolution NASA MODIS globe (it can take a while to download
#' # the image!)
#' globejs("http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73909/world.topo.bathy.200412.3x5400x2700.jpg")
#'
#' # Using global plots from the maptools, rworldmap, and sp packages.
#'
#' # Instead of using ready-made images of the earth, we can employ some
#' # incredibly capable R spatial imaging packages to produce globe images
#' # dynamically. With a little extra effort you can build globes with total
#' # control over how they are plotted.
#'
#' #------------------------------
#' # Using the R maptools package
#' #------------------------------
#' library("maptools")
#' library("threejs")
#' data(wrld_simpl)
#' 
#' bgcolor <- "#000025"
#' earth <- tempfile(fileext=".jpg")
#'
#'
#' # NOTE: Use antialiasing to smooth border boundary lines. But! Set the jpeg
#' # background color to the globe background color to avoid a visible aliasing
#' # effect at the the plot edges.
#'
#' jpeg(earth,width=2048,height=1024,quality=100,bg=bgcolor,antialias="default")
#' par(mar = c(0,0,0,0), pin = c(4,2), pty = "m",  xaxs = "i",
#'     xaxt = "n",       xpd = FALSE,  yaxs = "i", bty = "n", yaxt = "n")
#' plot(wrld_simpl, col="black", bg=bgcolor, border="cyan", ann=FALSE,
#"      axes=FALSE, xpd=FALSE, xlim=c(-180,180), ylim=c(-90,90),
#'      setParUsrBB=TRUE)
#' dev.off()
#' globejs(earth)
#'
#' See http://bwlewis.github.io/rthreejs for additional examples.
#'
#' @importFrom rjson toJSON
#' @import maps
#' @export
globejs <- function(
  img, lat=0, long=0,
  value=40,
  color="#00ffff",
  atmosphere=FALSE,
  bg="black",
  height = NULL,
  width = NULL, ...)
{
  # Strip alpha channel from colors
  i = grep("^#",color)
  if(length(i)>0)
  {
    j = nchar(color[i])>7
    if(any(j))
    { 
      color[i][j] = substr(color[i][j],1,7)
    }
  }
  i = grep("^#",bodycolor)
  if(length(i)>0) bodycolor = substr(bodycolor,1,7)
  i = grep("^#",emissive)
  if(length(i)>0) emissive = substr(emissive,1,7)
  i = grep("^#",lightcolor)
  if(length(i)>0) lightcolor = substr(lightcolor,1,7)
  i = grep("^#",bg)
  if(length(i)>0) bg = substr(bg,1,7)

  options = list(lat=lat, long=long, color=color,
                 value=value, atmosphere=atmosphere,
                 bodycolor=bodycolor, emissive=emissive,
                 lightcolor=lightcolor, bg=bg)
  additional_args = list(...)
  if(length(additional_args)>0) options = c(options, additional_args)
# Convert image files to dataURI using the texture function
  if(!is.list(img)) img=texture(img)
  x = c(img, options)
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
