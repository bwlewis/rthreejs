# Three.js and R

Three.js widgets for R and shiny. The package includes

* graphjs: an interactive force directed graph widget
* scatterplot3js:  a 3-d scatterplot widget similar to the scatterplot3d function
* globejs:  a widget that plots data and images on a 3-d globe

The widgets are easy to use and render directly in RStudio, in R markdown, in
Shiny applications, and from command-line R via a web browser.  They produce
high-quality interactive visualizations with just a few lines of R code.

Visualizations optionally use accelerated WebGL graphics, falling back to
non-accelerated graphics for systems without WebGL when possible. When WebGL is
available, the scatterplot3js function can produce fluid, interactive
pointclouds with hundreds of thousands of points.

See http://threejs.org for details on three.js.

See http://bwlewis.github.io/rthreejs  for an example.

This project is based on the htmlwidgets package. See
https://github.com/ramnathv/htmlwidgets for details and links to amazingly cool
visualization widgets for R.

## What's new in version 0.3.0 (December, 2016)

The `scatterplot3js` function was substantially improved and updated.

- The new `pch` option supports many point styles with size control.
- Interactive rotation and zooming are greatly improved and panning is now supported: press and hold the right mouse button (or touch equivalent) and move the mouse to pan.
- Mouse over labels are supported in WebGL renderings.
- Lines are supported too.

The `graphjs` function is completely new and now relies on `scatterplot3js`
under the hood.

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
