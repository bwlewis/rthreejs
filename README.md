# Three.js and R

Three.js widgets for R and shiny. The package includes

* graphjs: an interactive network visualization widget
* scatterplot3js: a 3-d scatterplot widget similar to, but more limited than, the scatterplot3d function
* globejs:  a widget that plots data and images on a 3-d globe

The widgets are easy to use and render directly in RStudio, in R markdown, in
Shiny applications, and from command-line R via a web browser.  They produce
high-quality interactive visualizations with just a few lines of R code.

Visualizations optionally use accelerated WebGL graphics, falling back to
non-accelerated graphics for systems without WebGL when possible.

See http://threejs.org for details on three.js.

See http://bwlewis.github.io/rthreejs  for an example.

This project is based on the htmlwidgets package. See
https://github.com/ramnathv/htmlwidgets for details and links to amazingly cool
visualization widgets for R.

# New in version 0.3.0 (January, 2017)

The new 0.3.0 package version includes major changes. The `scatterplot3js()`
function generally works as before but with more capabilities.  The `graphjs()`
function is very different with a new API more closely tied to the igraph
package.

The threejs package now depends on igrah. Why igraph?

1. If you're doing serious network analysis, you're probably already using igraph (or you should be).
2. We now use external graph layouts (either from igraph or elsewhere). This gives much greater
   graph layout flexibility, something I was looking for. But also removes the cute (but slow and
   crude) force-directed JavaScript animation previously used. To partially make up for that, a
   very basic but flexible graph animation scheme is now in place that's easy to use.

See https://bwlewis.github.io/rthreejs/animation/animation.html
and https://bwlewis.github.io/rthreejs/advanced/advanced.html for short tutorials on the
new graph animation capabilities.

Performance is generally much improved using extensive buffering and custom
WebGL shaders where needed. See https://bwlewis.github.io/rthreejs/ego/index.html for an example.

## What else is new in version 0.3.0

The `scatterplot3js()` function was substantially improved and updated.

- The new `pch` option supports many point styles with size control.
- Interactive rotation and zooming are greatly improved and panning is now supported: press and hold the right mouse button (or touch equivalent) and move the mouse to pan.
- Mouse over labels are supported in WebGL renderings.
- Lines are supported too.

The `graphjs()` function is completely new.

- Greater variety of WebGL vertex rendering ("pch") options, including spheres
  and much higher-performance options for large graphs.
- Graph layout is now external; for instance use one of the many superb
  igraph package graph layout options.
- Basic graph animation is supported.

## Install

Use the devtools package to install threejs directly from GitHub on any
R platform (Mac, Windows, Linux, ...). You'll need the 'devtools' package.
```r
if(!require("devtools")) install.packages("devtools")
devtools::install_github("bwlewis/rthreejs")
```

## Examples

See `?scatterplot3d` for more examples and detailed help.
```r
z <- seq(-10, 10, 0.1)
x <- cos(z)
y <- sin(z)
scatterplot3js(x, y, z, color=rainbow(length(z)))
```

The next example illustrates the globe widget by plotting the relative
population of some cities using data from the R maps package on a globe. It's
based on the JavaScript WebGL Globe Toolkit (https://github.com/dataarts) by
the Google Creative Lab Data Arts Team.
```r
runApp(system.file("examples/globe", package="threejs"))
```

For detailed help on the widgets and additional examples, see
```r
?scatterplot3js
?globejs
```


# Status
<a href="https://travis-ci.org/bwlewis/rthreejs">
<img src="https://travis-ci.org/bwlewis/rthreejs.svg?branch=master" alt="Travis CI status"></img>
</a>
[![codecov.io](https://codecov.io/github/bwlewis/rthreejs/coverage.svg?branch=master)](https://codecov.io/github/bwlewis/rthreejs?branch=master)
[![CRAN version](http://www.r-pkg.org/badges/version/threejs)](https://cran.r-project.org/packages=threejs)
![](http://cranlogs.r-pkg.org/badges/threejs)
