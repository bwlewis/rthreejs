#' scatterplot3js Three.js 3D scatterplot widget.
#'
#' A 3D scatterplot widget using three.js.
#'
#' @param x Either a vector of x-coordinate values or a  three-column
#' data matrix with three columns corresponding to the x,y,z
#' coordinate axes. Column labels, if present, are used as axis labels.
#' @param y (Optional) vector of y-coordinate values, not required if
#' \code{x} is a matrix.
#' @param z (Optional) vector of z-coordinate values, not required if
#' \code{x} is a matrix.
#' @param width The container div width.
#' @param height The container div height.
#' @param num.ticks A three-element vector with the suggested number of
#' ticks to display per axis. Set to NULL to not display ticks. The number
#' of ticks may be adjusted by the program.
#' @param color Either a single hex or named color name, or a vector of
#' hex or named color names as long as the number of data points to plot.
#' @param size The plot point radius, either as a single number or a
#' vector of sizes of length \code{nrow(x)}. A vector of sizes is only
#' supported by the \code{canvas} renderer. The \code{webgl} renderers accept
#' a single point size value.
#' @param flip.y Reverse the direction of the y-axis (the default value of
#' TRUE produces plots similar to those rendered by the R
#' \code{scatterplot3d} package).
#' @param grid Set FALSE to disable display of a grid.
#' @param stroke A single color stroke value (surrounding each point). Set to
#' null to omit stroke (only available in the CanvasRenderer).
#' @param renderer Select from available plot rendering techniques of
#' 'auto', 'canvas', 'webgl', or 'webgl-buffered'.
#' @param pch An optional data texture image prepared by the \code{texture}
#'   function used by the WebGL renderer to draw the points (only available
#'   in the WebGL renderer).
#'
#' @note
#' Use the \code{renderer} option to manually select from the available
#' rendering options.
#' The \code{canvas} renderer is the fallback rendering option when \code{webgl}
#' is not available. Select \code{auto} to automatically choose between
#' the two. The two renderers are slightly different
#' and have different available options (see above).
#' The \code{webgl-buffered} renderer is a variation of the \code{webgl}
#' renderer that uses a buffered geometry for large numbers of points.
#' It is automatically selected if \code{renderer} is not explicitly
#' specified and the number of points is greater than 10,000. The
#' \code{webgl-buffered} renderer can handle up to a million points
#' or so with reasonable performance on typical desktop graphics cards.
#'
#' @references
#' The three.js project \url{http://threejs.org}.
#' 
#' @examples
#' ## dontrun
#' # A stand-alone example
#' set.seed(1)
#' x <- matrix(rnorm(100*3),ncol=3)
#' scatterplot3js(x, color=heat.colors(100))
#'
#' # Example 1 from the scatterplot3d package (cf.)
#' z <- seq(-10, 10, 0.01)
#' x <- cos(z)
#' y <- sin(z)
#' scatterplot3js(x,y,z, rainbow(length(z)))
#'
#' # A shiny example
#' library("shiny")
#' runApp(system.file("examples/scatterplot",package="threejs"))
#' 
#' @seealso scatterplot3d, rgl
#' @importFrom rjson toJSON
#' @export
scatterplot3js <- function(
  x, y, z,
  height = NULL,
  width = NULL,
  axis = TRUE,
  num.ticks = c(6,6,6),
  color = "steelblue",
  stroke = "black",
  size = 1,
  flip.y = TRUE,
  grid = TRUE,
  renderer = c("auto","canvas","webgl", "webgl-buffered"),
  pch)
{
  # validate input
  if(!missing(y) && !missing(z)) x = cbind(x=x,y=y,z=z)
  if(ncol(x)!=3) stop("x must be a three column matrix")
  if(is.data.frame(x)) x = as.matrix(x)
  if(!is.matrix(x)) stop("x must be a three column matrix")
  if(missing(pch)) pch = texture(system.file("images/disc.png",package="threejs"))
  if(missing(renderer) && nrow(x)>10000)
  {
    renderer = "webgl-buffered"
  } else
  {
    renderer = match.arg(renderer)
  } 

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

  # create options
  options = as.list(environment())[-1]
  # javascript does not like dots in names
  i = grep("\\.",names(options))
  if(length(i)>0) names(options)[i] = gsub("\\.","",names(options)[i])

  # re-order so z points up as expected.
  x = x[,c(1,3,2)]

  # Our s3d.js Javascript code assumes a coordinate system in the unit box.
  # Scale x to fit in there.
  n = nrow(x)
  mn = apply(x,2,min)
  mx = apply(x,2,max)
  x = (x - rep(mn, each=n))/(rep(mx - mn, each=n))
  if(flip.y) x[,3] = 1-x[,3]
  
  # convert matrix to a JSON array required by scatterplotThree.js and strip
  # them (required by s3d.js)
  if(length(colnames(x))==3) options$labels = colnames(x)
  colnames(x)=c()
  x = toJSON(t(signif(x,4)))

  # Ticks
  if(!is.null(num.ticks))
  {
    if(length(num.ticks)!=3) stop("num.ticks must have length 3")

    t1 = seq(from=mn[1], to=mx[1], length.out=num.ticks[1])
    p1 = (t1 - mn[1])/(mx[1] - mn[1])
    t2 = axisTicks(c(mn[2],mx[2]),FALSE,nint=num.ticks[2])
    p2 = (t2 - mn[2])/(mx[2] - mn[2])
    t3 = seq(from=mn[3], to=mx[3], length.out=num.ticks[3])
    p3 = (t3 - mn[3])/(mx[3] - mn[3])
    if(flip.y) t3 = t3[length(t3):1]

    options$xticklab = sprintf("%.2f",t1)
    options$yticklab = sprintf("%.2f",t2)
    options$zticklab = sprintf("%.2f",t3)
    options$xtick = p1
    options$ytick = p2
    options$ztick = p3
  }

  # create widget
  htmlwidgets::createWidget(
      name = "scatterplotThree",
      x = list(data=x, options=options, pch=pch),
               width = width,
               height = height,
               htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
               package = "threejs")
}

#' @rdname threejs-shiny
#' @export
scatterplotThreeOutput <- function(outputId, width = "100%", height = "500px") {
    shinyWidgetOutput(outputId, "scatterplotThree", width, height,
                        package = "threejs")
}

#' @rdname threejs-shiny
#' @export
renderScatterplotThree <- function(expr, env = parent.frame(), quoted = FALSE) {
    if (!quoted) { expr <- substitute(expr) } # force quoted
    shinyRenderWidget(expr, scatterplotThreeOutput, env, quoted = TRUE)
}
