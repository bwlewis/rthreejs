# Three.js and R

Tools for and examples of working with three.js graphics in R and shiny.
See http://threejs.org for details on three.js.  Examples follow.

## NOTE!

These examples generally run best in WebGL-enabled browsers.  I have found that
either Firefox or Chrome generally produce the best experience.

## Examples

A shiny hello world:
```r
library("shiny")
runApp(system.file("examples/hello",package="threejs"))
```

A nice 3-d Canvas-based scatterplot:
```r
runApp(system.file("examples/scatterplot",package="threejs"))
```

Here is nifty example that plots the relative population of some cities using
data from the R maps package on
a globe. It's based on the Javascript WebGL Globe Toolkit
(https://github.com/dataarts) by the Google Creative Lab Data Arts Team.
```r
runApp(system.file("examples/globe",package="threejs"))
```
Run
```r
?globe.js
```
for examples and help plotting data and using other map images on the globe.

The globe example now works in shiny and by direct invocation! Non
WebGL-capable browsers are also better supported.

# Licenses

## Three.js

The MIT License

Copyright (c) 2010-2014 three.js authors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

## Globe example

Includes ideas and images from the dat.globe Javascript WebGL Globe Toolkit
http://dataarts.github.com/dat.globe,
Copyright 2011 Data Arts Team, Google Creative Lab
Licensed under the Apache License, Version 2.0
http://www.apache.org/licenses/LICENSE-2.0.

