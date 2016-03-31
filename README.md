# Three.js and R

Three.js widgets for R and shiny. The package includes

* graphjs: an interactive force directed graph widget
* scatterplot3js:  a 3-d scatterplot widget similar to the scatterplot3d function
* globejs:  a widget that plots data and images on a 3-d globe

The widgets are easy to use and render directly in RStudio, in R markdown, in
Shiny applications, and from command-line R via a web browser.  They produce
high-quality interactive visualizations with just a few lines of R code.

Visualizations optionally use accelerated WebGL graphics, falling back to
non-accelerated graphics for systems without WebGL. When WebGL is available,
the scatterplot3js function can produce fluid, interactive pointclouds with
hundreds of thousands of points.

See http://threejs.org for details on three.js.

See http://bwlewis.github.io/rthreejs  for an example.

This project is based on the new htmlwidgets package. See
https://github.com/ramnathv/htmlwidgets for details and links to amazingly cool
visualization widgets for R.

## What's new

Create force directed graphs the `graphjs` function.

The `scatterplot3js` function now supports `scatterplot3d`-like `xlim`, `ylim`
and `zlim` options.

The `globejs` function can draw arcs and bars.

We include mouse-over labels for labeling scatterplot3js points, thanks to
contributions from  Alexey Stukalov, https://github.com/alyst, thanks Alexey!


## NOTE!

These examples generally run best in WebGL-enabled viewers, including at least
Chrome, and recent versions of Internet Explorer web browsers. Users have had
some issues with Firefox on Windows. Safari on Mac OS X seems to fall back to
Canvas (not WebGL) rendering, but works.  We try to maintain basic support for
non-WebGL equipped browsers, but the performance and rendering quality will
generally be inferior to WebGL visualizations.

The examples run inside RStudio, acting similarly to normal R plots.  RStudio
renders them using Canvas right now, but an upcoming version of
RStudio will support WebGL.

## Install

Use the devtools package to install threejs directly from GitHub on any
R platform (Mac, Windows, Linux, ...). You'll need the 'devtools' package.
```r
if(!require("devtools")) install.packages("devtools")
devtools::install_github("bwlewis/rthreejs")
```

## Examples

The following example illustrates the 3D scatterplot widget.
```r
library("shiny")
runApp(system.file("examples/scatterplot", package="threejs"))
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


# Changes to the three.min.js JavaScript library

The package now includes a check for a manual (but simple) change required of the
three.min.js JavaScript library, discovered by Joe Cheng at RStudio. For details
see https://github.com/bwlewis/rthreejs/issues/15.

The required change is near the very beginning of the three.min.js file. Whenever
we update this library we need to change:

```html
// threejs.org/license
'use strict';var THREE={REVISION:
```

to
```html
// threejs.org/license
'use strict';var THREE=window.THREE={REVISION:
```

That enables the library to work correctly with the shiny `renderUI` functions.



# Status
<a href="https://travis-ci.org/bwlewis/rthreejs">
<img src="https://travis-ci.org/bwlewis/rthreejs.svg?branch=master" alt="Travis CI status"></img>
</a>
[![codecov.io](https://codecov.io/github/bwlewis/rthreejs/coverage.svg?branch=master)](https://codecov.io/github/bwlewis/rthreejs?branch=master)
[![CRAN version](http://www.r-pkg.org/badges/version/threejs)](https://cran.r-project.org/packages=threejs)
![](http://cranlogs.r-pkg.org/badges/threejs)
