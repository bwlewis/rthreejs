#' Interactive 3D Scatterplots
#'
#' A 3D scatterplot widget using three.js. Many options
#' follow the \code{scatterplot3d} package.
#'
#' @param x Either a vector of x-coordinate values or a  three-column
#' data matrix with columns corresponding to the x,y,z
#' coordinate axes. Column labels, if present, are used as axis labels.
#' @param y (Optional) vector of y-coordinate values, not required if
#' \code{x} is a matrix.
#' @param z (Optional) vector of z-coordinate values, not required if
#' \code{x} is a matrix.
#' @param width The container div width.
#' @param height The container div height.
#' @param axis A logical value that when \code{TRUE} indicates that the
#' axes will be displayed.
#' @param num.ticks A three-element vector with the suggested number of
#' ticks to display per axis. Set to NULL to not display ticks. The number
#' of ticks may be adjusted by the program.
#' @param x.ticklabs A vector of tick labels of length \code{num.ticks[1]}, or
#' \code{NULL} to show numeric labels.
#' @param y.ticklabs A vector of tick labels of length \code{num.ticks[2]}, or
#' \code{NULL} to show numeric labels.
#' @param z.ticklabs A vector of tick labels of length \code{num.ticks[3]}, or
#' \code{NULL} to show numeric labels.
#' @param color Either a single hex or named color name (all points same color),
#' or a vector of  hex or named color names as long as the number of data
#' points to plot.
#' @param size The plot point radius, either as a single number or a
#' vector of sizes of length \code{nrow(x)}.
#' @param cex.symbols Equivalent to the \code{size} parameter.
#' @param flip.y Reverse the direction of the y-axis (the default value of
#' TRUE produces plots similar to those rendered by the R
#' \code{scatterplot3d} package).
#' @param grid Set FALSE to disable display of a grid.
#' @param stroke A single color stroke value (surrounding each point). Set to
#' null to omit stroke (only available in the canvas renderer).
#' @param renderer Select from available plot rendering techniques of
#' 'auto' or 'canvas'. Set to 'canvas' to explicitly use non-accelerated Canvas
#' rendering, otherwise WebGL is used if available.
#' @param signif Number of significant digits used to represent point
#' coordinates. Larger numbers increase accuracy but slow plot generation
#' down.
#' @param bg  The color to be used for the background of the device region.
#' @param xlim Optional two-element vector of x-axis limits. Default auto-scales to data.
#' @param ylim Optional two-element vector of y-axis limits. Default auto-scales to data.
#' @param zlim Optional two-element vector of z-axis limits. Default auto-scales to data.
#' @param pch Optional point glyphs, see notes.
#' @param ... Additional options (see note).
#'
#' @return
#' An htmlwidget object that is displayed using the object's show or print method.
#' (If you don't see your widget plot, try printing it with the \code{print}) function. The
#' returned object includes a special \code{points3d} function for adding points to the
#' plot similar to \code{scatterplot3d}. See the note below and examples for details.
#'
#' @section Interacting with the plot:
#' Press and hold the left mouse button (or touch or trackpad equivalent) and move
#' the mouse to rotate the plot. Press and hold the right mouse button (or touch
#' equivalent) to pan. Use the mouse scroll wheel or touch equivalent to zoom.
#' If \code{labels} are specified (see below), moving the mouse pointer over
#' a point will display the label.
#'
#' @section Detailed plot options:
#' Use the \code{renderer} option to manually select from the available
#' rendering options.
#' The \code{canvas} renderer is the fallback rendering option when WebGL
#' is not available. The default setting \code{auto} automatically chooses
#' between
#' the two. The two renderers produce slightly different-looking output
#' and have different available options (see above). The WebGL renderer
#' can exhibit much better performance.
#'
#' Use the optional \code{...} argument to explicitly supply \code{axisLabels}
#' as a three-element character vector, see the examples below. A few additional
#' plot options are also supported:
#' \itemize{
#'   \item{"cex.lab"}{ font size scale factor for the axis labels}
#'   \item{"cex.axis"}{ font size scale factor for the axis tick labels}
#'   \item{"font.axis"}{ CSS font string used for all axis labels}
#'   \item{"font.symbols"}{ CSS font string used for plot symbols}
#'   \item{"font.main"}{ CSS font string used for main title text box}
#'   \item{"labels"}{ character vector of length \code{x} of point labels displayed when the mouse moves over the points}
#'   \item{"main"}{ Plot title text}
#'   \item{"top"}{ Top location in pixels of the plot title text}
#'   \item{"left"}{ Left location in pixels of the plot title text}
#' }
#' The default CSS font string is "48px Arial". Note that the format of this
#' font string differs from, for instance, the usual `par(font.axis)`.
#'
#' Use the \code{pch} option to specify points styles in WebGL-rendered plots.
#' \code{pch} may either be a single character value that applies to all points,
#' or a vector of character values of the same length as \code{x}. All
#' character values are used literally ('+', 'x', '*', etc.) except for the
#' following special cases:
#' \itemize{
#'   \item{"o"}{ Plotted points appear as 3-d spheres.}
#'   \item{"@"}{ Plotted points appear as nice circles.}
#'   \item{"."}{ Points appear as tiny squares.}
#' }
#' Character strings of more than one character are supported--see the examples.
#' The \code{@} and {.} option exhibit the best performance, consider using
#' one of those to plot large numbers of points.
#'
#' @section Plotting lines:
#' Lines are optionally drawn between points specified in \code{x, y, z} using
#' the following new plot options.
#' \itemize{
#'   \item{"from"}{ A numeric vector of indices of line starting vertices corresponding to entries in \code{x}.}
#'   \item{"to"}{ A numeric vector exactly as long as \code{from} of indices of line ending vertices corresponding
#'       to entries in \code{x}.}
#'   \item{"lcol"}{ Either a single color value or vector of values as long as \code{from} of line widths; line colors
#'      default to interpolating their vertex point colors.}
#'   \item{"lwd"}{ A single numeric value of line width (for all lines), defaults to 1.}
#'   \item{"linealpha"}{ A single numeric value between 0 and 1 inclusive setting the transparency of all plot lines,
#'      defaulting to 1.}
#' }
#'
#' @note
#' Points with missing values are omitted from the plot, please try to avoid missing values
#' in \code{x, y, z}.
#'
#' @references
#' The three.js project \url{http://threejs.org}.
#'
#' @examples
#' # Example 1 from the scatterplot3d package (cf.)
#' z <- seq(-10, 10, 0.1)
#' x <- cos(z)
#' y <- sin(z)
#' scatterplot3js(x, y, z, color=rainbow(length(z)))
#'
#' # Same example with explicit axis labels
#' scatterplot3js(x, y, z, color=rainbow(length(z)), axisLabels=c("a", "b", "c"))
#'
#' # Same example showing multiple point styles with pch
#' scatterplot3js(x, y, z, color=rainbow(length(z)),
#'                pch=sample(c(".", "o", letters), length(x), replace=TRUE))
#'
#' # Pretty point cloud example, should run this with WebGL!
#' # Note the use of pch="." for the most efficient rendering.
#' N     <- 20000
#' theta <- runif(N) * 2 * pi
#' phi   <- runif(N) * 2 * pi
#' R     <- 1.5
#' r     <- 1.0
#' x <- (R + r * cos(theta)) * cos(phi)
#' y <- (R + r * cos(theta)) * sin(phi)
#' z <- r * sin(theta)
#' d <- 6
#' h <- 6
#' t <- 2 * runif(N) - 1
#' w <- t^2 * sqrt(1 - t^2)
#' x1 <- d * cos(theta) * sin(phi) * w
#' y1 <- d * sin(theta) * sin(phi) * w
#' i <- order(phi)
#' j <- order(t)
#' col <- c( rainbow(length(phi))[order(i)],
#'          rainbow(length(t), start=0, end=2/6)[order(j)])
#' M <- cbind(x=c(x, x1), y=c(y, y1), z=c(z, h*t))
#' scatterplot3js(M, size=0.5, color=col, bg="black", pch=".")
#'
#' # Adding points to a plot with points3d
#' set.seed(1)
#' lim <- c(-3, 3)
#' x <- scatterplot3js(rnorm(5),rnorm(5),rnorm(5), xlim=lim, ylim=lim, zlim=lim)
#' a <- x$points3d(rnorm(3), rnorm(3), rnorm(3) / 2, color="red")
#'
#' # Plot text using 'pch' (we label some points in this example)
#' set.seed(1)
#' x <- rnorm(5); y <- rnorm(5); z <- rnorm(5)
#' a <- scatterplot3js(x, y, z, pch=".", xlim=lim, ylim=lim, zlim=lim)
#' b <- a$points3d(x + 0.2, y + 0.2, z, color="red", pch=paste("point", 1:5))
#' print(b)
#'
#' # Explicitly use the Canvas renderer
#' N <- 100
#' i <- sample(3, N, replace=TRUE)
#' x <- matrix(rnorm(N*3),ncol=3)
#' lab <- c("small", "bigger", "biggest")
#' scatterplot3js(x, color=rainbow(N), size=i, renderer="canvas")
#' # Same example, but with WebGL spheres (if available)
#' scatterplot3js(x, color=rainbow(N), size=i)
#'
#' \dontrun{
#'   # A shiny example
#'   shiny::runApp(system.file("examples/scatterplot",package="threejs"))
#' }
#'
#' @seealso scatterplot3d, rgl
#' @importFrom stats na.omit
#' @export
scatterplot3js <- function(
  x, y, z,
  height = NULL,
  width = NULL,
  axis = TRUE,
  num.ticks = c(6,6,6),
  x.ticklabs = NULL,
  y.ticklabs = NULL,
  z.ticklabs = NULL,
  color = "steelblue",
  size = cex.symbols,
  stroke = "black",
  flip.y = TRUE,
  grid = TRUE,
  renderer = c("auto", "canvas"),
  signif = 8,
  bg = "#ffffff",
  cex.symbols = 1,
  xlim, ylim, zlim, pch, ...) {
  # validate input
  if (!missing(y) && !missing(z)) {
    if(is.matrix(x))
      stop("Specify either: A three-column matrix x or, Three vectors x, y, and z. See ?scatterplot3js for help.")
    x <- cbind(x = x, y = y, z = z)
  }
  if(is.list(x))
  {
    if (!all(lapply(x, ncol) == 3)) stop("x must be a three column matrix")
    x <- lapply(x, function(y) {
        ans <- if(is.data.frame(y)) as.matrix(y) else y
        na.omit(ans)
      })
  } else
  {
    if (ncol(x) != 3) stop("x must be a three column matrix")
    if (is.data.frame(x)) x <- as.matrix(x)
    if (!is.matrix(x)) stop("x must be a three column matrix")
    x <- list(na.omit(x))
  }
  NROW <- nrow(x[[1]])
  if(missing(pch)) pch <- rep("o", NROW)
  if(length(pch) != NROW) pch <- rep_len(pch, NROW)
  renderer <- match.arg(renderer)

  # Strip alpha channel from colors and standardize color values
  if(!is.list(color)) color <- list(color)
  color <- lapply(color, function(x) col2rgb(x, alpha=TRUE))
  a <- lapply(color, function(x) as.vector(x[4, ]) / 255)   # alpha values
  color <- lapply(color, function(y) apply(y, 2, function(x) rgb(x[1], x[2], x[3], maxColorValue=255)))

  bg <- sub("^(#[[:xdigit:]]{6}+).*$","\\1", bg, perl = TRUE)

  # create options
  options <- c(as.list(environment()), list(...))
  options <- options[!(names(options) %in% c("x", "y", "z", "i", "j", "a"))]

  # javascript does not like dots in names
  names(options) <- gsub("\\.", "", names(options))

  # re-order so z points up as expected.
  x <- lapply(x, function (y) y[, c(1, 3, 2), drop=FALSE])

  # set axis labels if they exist
  if (!is.null(colnames(x[[1]])) && is.null(options$axisLabels))
    options$axisLabels <- colnames(x[[1]])[1:3]
  # Avoid asJson named vector warning
  colnames(x[[1]]) <- NULL

  # The Javascript code assumes a coordinate system in the unit box.  Scale x
  # to fit in there.
  n <- NROW
  mn <- Reduce(pmin, lapply(x, function(y) apply(y[, 1:3, drop=FALSE], 2, min)))
  mx <- Reduce(pmax, lapply(x, function(y) apply(y[, 1:3, drop=FALSE], 2, max)))
  if (!missing(xlim) && length(xlim) == 2) {
    mn[1] <- xlim[1]
    mx[1] <- xlim[2]
  }
  if (!missing(ylim) && length(ylim) == 2) {
    mn[3] <- ylim[1]
    mx[3] <- ylim[2]
  }
  if (!missing(zlim) && length(zlim) == 2) {
    mn[2] <- zlim[1]
    mx[2] <- zlim[2]
  }
  options$mn <- mn
  options$mx <- mx
  x <- lapply(x, function(x) (x[, 1:3, drop=FALSE] - rep(mn, each = n)) / (rep(mx - mn, each = n)))

  if (flip.y)
  {
    x <- lapply(x, function(y)
      {
        y[, 3] <- 1 - y[, 3]
        y
      })
  }

  if("center" %in% names(options) && options$center) # not yet documented, useful for graph
  {
    x <- lapply(x, function(y) 2 * (y - 0.5))
  }
  if(!("linealpha" %in% names(options))) options$linealpha <- 1
  if(!("alpha" %in% names(options))) options$alpha <- a

  # convert matrix to a array required by scatterplotThree.js and strip
  x <- lapply(x, function(y) as.vector(t(signif(y, signif))))
  options$vertices <- x

  # Ticks
  if (!is.null(num.ticks))
  {
    if (length(num.ticks) != 3) stop("num.ticks must have length 3")
    num.ticks <- pmax(1, num.ticks[c(1,3,2)])

    t1 <- seq(from=mn[1], to=mx[1], length.out=num.ticks[1])
    p1 <- (t1 - mn[1]) / (mx[1] - mn[1])
    t2 <- seq(from=mn[2], to=mx[2], length.out=num.ticks[2])
    p2 <- (t2 - mn[2]) / (mx[2] - mn[2])
    t3 <- seq(from=mn[3], to=mx[3], length.out=num.ticks[3])
    p3 <- (t3 - mn[3]) / (mx[3] - mn[3])
    if(flip.y) t3 <- t3[length(t3):1]

    pfmt <- function(x, d=2)
    {
      ans <- sprintf("%.2f", x)
      i <- (abs(x) < 0.01 && x != 0)
      if(any(i))
      {
        ans[i] <- sprintf("%.2e", x)
      }
      ans
    }

    options$xticklab <- pfmt(t1)
    options$yticklab <- pfmt(t2)
    options$zticklab <- pfmt(t3)
    if(!is.null(x.ticklabs)) options$xticklab <- x.ticklabs
    if(!is.null(y.ticklabs)) options$zticklab <- y.ticklabs
    if(!is.null(z.ticklabs)) options$yticklab <- z.ticklabs
    options$xtick <- p1
    options$ytick <- p2
    options$ztick <- p3
  }

  # lines
  if("from" %in% names(options))
  {
    if(!("to" %in% names(options))) stop("both from and to must be specified")
    if(!is.list(options$from)) options$from <- list(options$from)
    if(!is.list(options$to)) options$to <- list(options$to)
    f <- function(x) # zero index and make sure each element is an array in JavaScript
    {
      a <- as.integer(x) - 1
      if(length(a) == 1) a <- list(a)
      a
    }
    options$from <- Map(f, options$from)
    options$to <- Map(f, options$to)
    if(!("lwd" %in% names(options))) options$lwd <- 1L
  }

  # create widget
  htmlwidgets::createWidget(
          name = "scatterplotThree",
          x = options,
          width = width,
          height = height,
          htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
          package = "threejs")
}

#' @rdname threejs-shiny
#' @export
scatterplotThreeOutput <- function(outputId, width="100%", height="500px") {
    shinyWidgetOutput(outputId, "scatterplotThree", width, height, package = "threejs")
}

#' @rdname threejs-shiny
#' @export
renderScatterplotThree <- function(expr, env = parent.frame(), quoted = FALSE) {
    if (!quoted) expr <- substitute(expr) # force quoted
    shinyRenderWidget(expr, scatterplotThreeOutput, env, quoted = TRUE)
}
