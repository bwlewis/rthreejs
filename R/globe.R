#' Plot Data on 3D Globes
#'
#' Plot points, arcs and images on a globe in 3D using Three.js. The globe
#' can be rotated and and zoomed.
#'
#' @param img A character string representing a file path or URI of an image to plot on the globe surface.
#' @param lat Optional data point decimal latitudes, must be of same length as \code{long} (negative values indicate south, positive north).
#' @param long Optional data point decimal longitudes, must be of same length as \code{lat} (negative values indicate west, positive east).
#' @param color Either a single color value indicating the color of all data points, or a vector of values of the same length as \code{lat} indicating color of each point.
#' @param value Either a single value indicating the height of all data points, or a vector of values of the same length as \code{lat} indicating height of each point.
#' @param arcs Optional four-column data frame specifying arcs to plot. The columns of the data frame, in order, must indicate the starting latitude, starting longitude, ending latitude, and ending longitude.
#' @param arcsColor Either a single color value indicating the color of all arcs, or a vector of values of the same length as the number of rows of \code{arcs}.
#' @param arcsLwd Either a single value indicating the line width of all arcs, or a vector of values of the same length as the number of rows of \code{arcs}.
#' @param arcsHeight A single value between 0 and 1 controlling the height above the globe of each arc.
#' @param arcsOpacity A single value between 0 and 1 indicating the opacity of all arcs.
#' @param atmosphere TRUE enables WebGL atmpsphere effect.
#' @param bg Plot background color.
#' @param width The container div width.
#' @param height The container div height.
#' @param ... Additional arguments to pass to the three.js renderer (see
#' below for more information on these options).
#'
#' @return
#' An htmlwidget object (displayed using the object's show or print method).
#'
#' @note
#' The \code{img} argument specifies the WebGL texture image to wrap on a
#' sphere. If you plan to plot points using \code{lat} and \code{lon}
#' the image must be a plate carree (aka lat/long) equirectangular
#' map projection; see
#' \url{https://en.wikipedia.org/wiki/Equirectangular_projection} for
#' details.
#' Lat/long maps are commonly found for most planetary bodies in the
#' solar system, and are also easily generated directly in R
#' (see the references and examples below).
#'
#' @section Available rendering options:
#' \itemize{
#'   \item{"bodycolor"}{ The diffuse reflective color of the globe.}
#'   \item{"emissive"}{ The emissive color of the globe object.}
#'   \item{"lightcolor"}{ The color of the ambient light in the scene.}
#'   \item{"fov"}{ The initial field of view, default is 35.}
#'   \item{"rotationlat"}{ The initial globe latitudinal rotation in radians, default is 0.}
#'   \item{"rotationlong"}{ The initial globe longitudinal rotation in radians, default is 0.}
#'   \item{"pointsize"}{ The numeric size of the points/bars, default is 1.}
#'   \item{"renderer"}{ Manually set the three.js renderer to one of 'auto' or 'canvas'.
#'        The canvas renderer works across a greater variety of
#'        viewers and browsers. The default setting of 'auto' automatically chooses
#'        WebGL rendering if it's available.}
#' }
#' Specify colors with standard color names or hex color representations.
#' The default values (well-suited to many earth-like map images) are
#' \code{lightcolor = "#aaeeff"}, \code{emissive = "#0000ff"}, and \code{bodycolor = "#0000ff"}.
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
#' Includes images adapted from the NASA Earth Observatory and NASA Jet Propulsion Laboratory.
#' World image link: \url{http://goo.gl/GVjxJ}.
#'
#' @examples
#' # Plot flights to frequent destinations from Callum Prentice's
#' # global flight data set,
#' # http://callumprentice.github.io/apps/flight_stream/index.html
#' data(flights)
#' # Approximate locations as factors
#' dest   <- factor(sprintf("%.2f:%.2f",flights[,3], flights[,4]))
#' # A table of destination frequencies
#' freq <- sort(table(dest), decreasing=TRUE)
#' # The most frequent destinations in these data, possibly hub airports?
#' frequent_destinations <- names(freq)[1:10]
#' # Subset the flight data by destination frequency
#' idx <- dest %in% frequent_destinations
#' frequent_flights <- flights[idx, ]
#' # Lat/long and counts of frequent flights
#' ll <- unique(frequent_flights[,3:4])
#' # Plot frequent destinations as bars, and the flights to and from
#' # them as arcs. Adjust arc width and color by frequency.
#' globejs(lat=ll[,1], long=ll[,2], arcs=frequent_flights,
#'         arcsHeight=0.3, arcsLwd=2, arcsColor="#ffff00", arcsOpacity=0.15,
#'         atmosphere=TRUE, color="#00aaff", pointsize=0.5)
#'
#' # Plot populous world cities from the maps package.
#' library(threejs)
#' library(maps)
#' data(world.cities, package="maps")
#' cities <- world.cities[order(world.cities$pop, decreasing=TRUE)[1:1000],]
#' value  <- 100 * cities$pop / max(cities$pop)
#' col <- colorRampPalette(c("cyan", "lightgreen"))(10)[floor(10 * value/100) + 1]
#' globejs(lat=cities$lat, long=cities$long, value=value, color=col, atmosphere=TRUE)
#'
#' # Plot the data on the moon:
#' moon <- system.file("images/moon.jpg", package="threejs")
#' globejs(img=moon, bodycolor="#555555", emissive="#444444",
#'          lightcolor="#555555", lat=cities$lat, long=cities$long,
#'          value=value, color=col)
#'
#' \dontrun{
#' # Plot a high-resolution NASA MODIS globe, setting colors to more closely reproduce
#' # the natural image colors. Note that this example can can take a while to download!
#' globejs("http://goo.gl/GVjxJ",
#'         emmisive="#000000", bodycolor="#000000", lightcolor="#aaaa44")
#'
#' # Using global plots from the maptools, rworldmap, or sp packages.
#'
#' # Instead of using ready-made images of the earth, we can use
#' # many R spatial imaging packages to produce globe images
#' # dynamically. With a little extra effort you can build globes with total
#' # control over how they are plotted.
#'
#' library(maptools)
#' library(threejs)
#' data(wrld_simpl)
#' 
#' bgcolor <- "#000025"
#' earth <- tempfile(fileext=".jpg")
#'
#' # NOTE: Use antialiasing to smooth border boundary lines. But! Set the jpeg
#' # background color to the globe background color to avoid a visible aliasing
#' # effect at the the plot edges.
#'
#' jpeg(earth, width=2048, height=1024, quality=100, bg=bgcolor, antialias="default")
#' par(mar = c(0,0,0,0), pin = c(4,2), pty = "m",  xaxs = "i",
#'     xaxt = "n",       xpd = FALSE,  yaxs = "i", bty = "n", yaxt = "n")
#' plot(wrld_simpl, col="black", bg=bgcolor, border="cyan", ann=FALSE,
#"      axes=FALSE, xpd=FALSE, xlim=c(-180,180), ylim=c(-90,90),
#'      setParUsrBB=TRUE)
#' dev.off()
#' globejs(earth)
#'
#' # A shiny example:
#' shiny::runApp(system.file("examples/globe",package="threejs"))
#' }
#' 
#' # See http://bwlewis.github.io/rthreejs for additional examples.
#' @export
globejs <- function(
  img=system.file("images/world.jpg",  package="threejs"),
  lat, long,
  value=40,
  color="#00ffff",
  arcs,
  arcsColor="#99aaff",
  arcsHeight=0.4,
  arcsLwd=1,
  arcsOpacity=0.2,
  atmosphere=FALSE,
  bg="black",
  height = NULL,
  width = NULL, ...)
{
  if(missing(lat) || missing(long))
  {
    lat = NULL
    long = NULL
  }
  # Strip alpha channel from colors
  i = grep("^#", color)
  if(length(i) > 0)
  {
    j = nchar(color[i]) > 7
    if(any(j))
    {
      color[i][j] = substr(color[i][j], 1, 7)
    }
  }
  i = grep("^#", arcsColor)
  if(length(i) > 0)
  {
    j = nchar(arcsColor[i]) > 7
    if(any(j))
    {
      arcsColor[i][j] = substr(arcsColor[i][j], 1, 7)
    }
  }
  i = grep("^#", bg)
  if(length(i) > 0) bg = substr(bg, 1, 7)
  if(missing(arcs))
    arcs = NULL
  else
  {
    arcs = data.frame(arcs)
    names(arcs) = c("fromlat", "fromlong", "tolat", "tolong")
  }
  arcsHeight = max(min(arcsHeight, 1), 0.2)
  arcsOpacity = max(min(arcsOpacity, 1), 0)

  options = list(lat=lat, long=long, color=color, arcsOpacity=arcsOpacity,
                 value=value, atmosphere=atmosphere, bg=bg, arcs=arcs,
                 arcsColor=arcsColor, arcsLwd=arcsLwd, arcsHeight=arcsHeight)
  additional_args = list(...)
  if(length(additional_args) > 0) options = c(options, additional_args)
# Clean up optional color arguments
  if("bodycolor" %in% names(options))
  {
    i = grep("^#",options$bodycolor)
    if(length(i) > 0) options$bodycolor = substr(options$bodycolor,1,7)
  }
  if("emissive" %in% names(options))
  {
    i = grep("^#",options$emissive)
    if(length(i) > 0) options$emissive = substr(options$emissive,1,7)
  }
  if("lightcolor" %in% names(options))
  {
    i = grep("^#",options$lightcolor)
    if(length(i) > 0) options$lightcolor = substr(options$lightcolor,1,7)
  }

# Convert image files to dataURI using the texture function
  if (!is.list(img)) img = texture(img)
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
    if (!quoted) {
      expr = substitute(expr)
    } # force quoted
    shinyRenderWidget(expr, globeOutput, env, quoted = TRUE)
}
