#' Interactive 3D Scatterplots
#'
#' A 3D scatterplot widget using three.js. Many options
#' follow the \code{scatterplot3d} function from the eponymous package.
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
#' or a vector of #' hex or named color names as long as the number of data
#' points to plot.
#' @param size The plot point radius, either as a single number or a
#' vector of sizes of length \code{nrow(x)}. A vector of sizes is only
#' supported by the \code{canvas} renderer. The \code{webgl} renderer accepts
#' a single size value for all points. Equivalent to \code{cex.symbols}.
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
#' @note
#' Press and hold the left mouse button (or touch or trackpad equivalent) and move
#' the mouse to rotate the plot. Press and hold the right mouse button (or touch
#' equivalent) to pan. Use the mouse scroll wheel or touch equivalent to zoom.
#'
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
#' standard plot options are also supported:
#' \itemize{
#'   \item{"cex.lab"}{ font size scale factor for the axis labels}
#'   \item{"cex.axis"}{ font size scale factor for the axis tick labels }
#'   \item{"font.axis"}{ CSS font string used for all axis labels}
#'   \item{"font.symbols"}{ CSS font string used for plot symbols}
#' }
#' The default CSS font string is "48px Arial". Note that the format of this
#' font string differs from, for instance, the usual `par(font.lab)`.
#'
#' The returned object includes a \code{points3d} function that can add points
#' to a plot, returning a new htmlwidget plot object. The function signature
#' is a subset of the full \code{scatterplot3js} function:
#'
#'  \code{points3d (x, y, z, color="steelblue", size=1)}
#'
#' It allows you to add points to a plot using the same syntax as \code{scatterplot3js}
#' with optionally specified color, size. New points are plotted in
#' the same scale as the existing plot. See below for an
#' example.
#'
#' Use the \code{pch} option to specify points styles in WebGL-rendered plots.
#' \code{pch} may either be a single character value that applies to all points,
#' or a vector of character values of the same length as \code{x}. All
#' character values are used literally ('+', 'x', '*', etc.) except for the
#' following special cases:
#' \itemize{
#'   \item{"o"}{ Plotted points appear as 3-d spheres.}
#'   \item{"."}{ Points appear as tiny squares; use this
#'              \code{pch} style for large numbers of points.}
#' }
#' Character strings of more than one character are supported.
#'
#' Note that points with missing values are omitted from the plot.
#'
#' @references
#' The three.js project \url{http://threejs.org}.
#'
#' @examples
#' # Gumball machine using the Canvas renderer
#' N <- 100
#' i <- sample(3, N, replace=TRUE)
#' x <- matrix(rnorm(N*3),ncol=3)
#' lab <- c("small", "bigger", "biggest")
#' scatterplot3js(x, color=rainbow(N), size=i, renderer="canvas")
#'
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
#' # Adding labels using 'pch'
#' set.seed(1)
#' x <- rnorm(5); y <- rnorm(5); z <- rnorm(5)
#' a <- scatterplot3js(x, y, z, pch=".", xlim=lim, ylim=lim, zlim=lim)
#' b <- a$points3d(x + 0.3, y + 0.3, z, color="red", pch=paste("point", 1:5))
#' print(b)
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
  if (ncol(x) != 3) stop("x must be a three column matrix")
  if (is.data.frame(x)) x <- as.matrix(x)
  if (!is.matrix(x)) stop("x must be a three column matrix")
  x <- na.omit(x)
  if(missing(pch)) pch <- rep("o", nrow(x))
  if(length(pch) != nrow(x)) pch <- rep_len(pch, nrow(x))
  renderer = match.arg(renderer)

  # Strip alpha channel from colors REGEXP: Optional leading #, then takes
  # first 6 hex characters and discards the rest. If it doesn't match the string
  # remains unaltered.
  color <- sub("^(#[[:xdigit:]]{6}+).*$","\\1", color, perl = TRUE)
  bg <- sub("^(#[[:xdigit:]]{6}+).*$","\\1", bg, perl = TRUE)

  # create options
  options <- c(as.list(environment()), list(...))
  options <- options[!(names(options) %in% c("x", "y", "z", "i", "j"))]

  # javascript does not like dots in names
  names(options) <- gsub("\\.", "", names(options))

  # re-order so z points up as expected.
  x <- x[, c(1, 3, 2), drop=FALSE]

  # set axis labels if they exist
  if (!is.null(colnames(x)) && is.null(options$axisLabels))
    options$axisLabels <- colnames(x)[1:3]
  # Avoid asJson named vector warning
  colnames(x) <- NULL

  # The Javascript code assumes a coordinate system in the unit box.  Scale x
  # to fit in there.
  n <- nrow(x)
  mn <- apply(x[, 1:3, drop=FALSE], 2, min)
  mx <- apply(x[, 1:3, drop=FALSE], 2, max)
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
  x[, 1:3] <- (x[, 1:3, drop=FALSE] - rep(mn, each = n)) / (rep(mx - mn, each = n))

  if(flip.y) x[, 3] = 1 - x[, 3]

  mdata <- x # stash for return result

  # convert matrix to a JSON array required by scatterplotThree.js and strip
  x <- as.vector(t(signif(x, signif)))

  # Ticks
  if (!is.null(num.ticks))
  {
    if (length(num.ticks) != 3) stop("num.ticks must have length 3")
    num.ticks = num.ticks[c(1,3,2)]

    t1 = seq(from=mn[1], to=mx[1], length.out=num.ticks[1])
    p1 = (t1 - mn[1]) / (mx[1] - mn[1])
    t2 = seq(from=mn[2], to=mx[2], length.out=num.ticks[2])
    p2 = (t2 - mn[2]) / (mx[2] - mn[2])
    t3 = seq(from=mn[3], to=mx[3], length.out=num.ticks[3])
    p3 = (t3 - mn[3]) / (mx[3] - mn[3])
    if(flip.y) t3 = t3[length(t3):1]

    pfmt = function(x,d=2)
    {
      ans = sprintf("%.2f",x)
      i = (abs(x) < 0.01 && x != 0)
      if(any(i))
      {
        ans[i] = sprintf("%.2e",x)
      }
      ans
    }

    options$xticklab = pfmt(t1)
    options$yticklab = pfmt(t2)
    options$zticklab = pfmt(t3)
    if(!is.null(x.ticklabs)) options$xticklab = x.ticklabs
    if(!is.null(y.ticklabs)) options$zticklab = y.ticklabs
    if(!is.null(z.ticklabs)) options$yticklab = z.ticklabs
    options$xtick = p1
    options$ytick = p2
    options$ztick = p3
  }

  # create widget
  ans = htmlwidgets::createWidget(
          name = "scatterplotThree",
          x = list(data = x, options = options, pch = pch, bg = bg),
          width = width,
          height = height,
          htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
          package = "threejs")

  # Add a reference to this call to support adding points
  ans$points3d <- points3d_generator(data = mdata,
                                    options = options,
                                    bg = bg,
                                    width = width,
                                    height = height,
                                    signif = signif)
  ans
}

#' @rdname threejs-shiny
#' @export
scatterplotThreeOutput = function(outputId, width="100%", height="500px") {
    shinyWidgetOutput(outputId, "scatterplotThree", width, height, package = "threejs")
}

#' @rdname threejs-shiny
#' @export
renderScatterplotThree = function(expr, env = parent.frame(), quoted = FALSE) {
    if (!quoted) {
      expr = substitute(expr)
    } # force quoted
    shinyRenderWidget(expr, scatterplotThreeOutput, env, quoted = TRUE)
}


# Support for adding points to a plot
points3d_generator = function(data, options, bg, width, height, signif)
{
  function(x, y, z, r = NULL, color="steelblue", size=1, pch="o", ...)
  {
    if (!missing(y) && !missing(z)) {
      if(is.matrix(x))
        stop("Specify either: 1) a three-column matrix x or, 2) three vectors x, y, and z. See ?scatterplot3js for help.")
      x <- cbind(x = x, y = y, z = z)
    }
    if (ncol(x) != 3) stop("x must be a three column matrix")
    if (is.data.frame(x)) x = as.matrix(x)
    if (!is.matrix(x)) stop("x must be a three column matrix")
    x <- na.omit(x)

    # Strip alpha channel from colors
    color <- sub("^#([[:xdigit:]]{6}+).*$","\\1", color, perl = TRUE)

    # re-order so z points up as expected.
    x <- x[, c(1, 3, 2), drop=FALSE]
    n <- nrow(x)
    x[, 1:3] <- (x[, 1:3, drop=FALSE] - rep(options$mn, each = n)) / (rep(options$mx - options$mn, each = n))
    if (options$flipy) x[, 3] <- 1 - x[, 3]

    # Combine new data with old data
    n_old <- nrow(data)
    data <- rbind(data, x)
    local_options <- options
    x <- as.vector(t(signif(data,signif)))
    # size, color, and label settings for old and new points
    if (length(options$size) + length(size) == nrow(data)) {
      local_options$size <- c(options$size, size)
    } else {
      local_options$size <- c(rep(options$size, length.out = n_old), rep(size, length.out=n))
    }
    if (length(options$color) + length(color) == nrow(data)) {
      local_options$color <- c(options$color, color)
    } else {
      local_options$color <- c(rep(options$color, length.out=n_old), rep(color, length.out=n))
    }
    if (length(options$pch) + length(pch) == nrow(data)) {
      local_options$pch <- c(options$pch, pch)
    } else {
      local_options$pch <- c(rep(options$pch, length.out=n_old), rep(pch, length.out=n))
    }
    options <- local_options
    # create widget
    ans <- htmlwidgets::createWidget(
      name = "scatterplotThree",
      x = list(data = x, options = options, bg = bg),
      width = width,
      height = height,
      htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE),
      package = "threejs")
    ans$points3d <- points3d_generator(data = data, options = options, bg = bg,
                                      width = width, height = height, signif = signif)
    ans
  }
}
