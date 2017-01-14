HTMLWidgets.widget(
{
  name: "scatterplotThree",
  type: "output",

  initialize: function(el, width, height)
  {
    var g = new Widget.scatter();
    g.init(el, parseInt(width), parseInt(height));
    return {widget: g, width: parseInt(width), height: parseInt(height)};
  },

  resize: function(el, width, height, obj)
  {
    obj.width = parseInt(width);
    obj.height = parseInt(height);
    obj.widget.renderer.setSize(width, height);
  },

  renderValue: function(el, x, obj)
  {
    obj.widget.create_plot(x);
    obj.widget.renderer.setSize(obj.width, obj.height);
    obj.widget.animate(); 
  }
})


/* Define a scatter object with methods
 * init(el, width, height)
 * create_plot(options)
 * animate()
 * update()
 */
var Widget = Widget || {};
Widget.scatter = function()
{
//  var options = options || {};
  this.idle = true;
  this.frame = -1;   // current animation frame
  this.nframes = 0; // total frames

  var camera, controls, scene;
  var _this = this;

  _this.init = function (el, width, height)
  {
    if(Detector.webgl)
    {
      _this.renderer = new THREE.WebGLRenderer({alpha: true});
      _this.renderer.GL = true;
    } else {
      _this.renderer = new THREE.CanvasRenderer();
      _this.renderer.GL = false;
    }
    _this.renderer.sortObjects = false; // we control z-order with two scenes
    _this.renderer.autoClearColor = false;
    _this.renderer.setSize(el.innerWidth, el.innerHeight);
    _this.el = el;

    // Info box for mouse-over labels and generic text
    var info = document.createElement("div");
    var id_attr = document.createAttribute("id");
    id_attr.nodeValue = "graph-info";
    info.setAttributeNode(id_attr);
    info.style.textAlign = "center";
    info.style.zIndex = 100;
    info.style.fontFamily = "Sans";
    info.style.fontSize = "x-large";
    info.style.position = "absolute";
    info.style.top = "10px";
    info.style.left = "10px";
    el.appendChild(info);
    _this.infobox = info;
    _this.fgcss = "#000000";
    _this.main = ""; // default text in infobox
    _this.mousethreshold = 0.02; // default mouse over id threshold

    el.onmousemove = function(ev)
    { 
      if(ev.preventDefault) ev.preventDefault();
      var mouse = new THREE.Vector2();
      var raycaster = new THREE.Raycaster();
      raycaster.params.Points.threshold = _this.mousethreshold;
      var canvasRect = this.getBoundingClientRect();
      mouse.x = 2 * (ev.clientX - canvasRect.left) / canvasRect.width - 1;
      mouse.y = -2 * (ev.clientY - canvasRect.top) / canvasRect.height + 1;
      raycaster.setFromCamera(mouse, camera);
      var I = raycaster.intersectObject(_this.pointgroup, true);
      if(I.length > 0)
      {
        if(I[0].object.type == "Points")
        {
          if(I[0].object.geometry.labels[I[0].index].length > 0) printInfo(I[0].object.geometry.labels[I[0].index]);
        } else if(I[0].object.type == "Mesh")
        {
          if(I[0].object.label.length > 0) printInfo(I[0].object.label);
        }
      } else
      {
        printInfo(_this.main);
      }
      if(_this.idle)
      {
        _this.idle = false;
        _this.animate();
      }
    }

    camera = new THREE.PerspectiveCamera(40, width / height, 1e-5, 100);
    camera.position.z = 2.0;
    camera.position.x = 2.5;
    camera.position.y = 1.2;

    controls = new THREE.TrackballControls(camera, el);
    controls.rotateSpeed = 0.5;
    controls.zoomSpeed = 4.2;
    controls.panSpeed = 1;
    controls.noZoom = false;
    controls.noPan = false;
    controls.staticMoving = false;
    controls.dynamicDampingFactor = 0.2;
    controls.addEventListener('change', render);

    scene = new THREE.Scene();
    el.appendChild(_this.renderer.domElement);
  }

  // create_plot
  _this.create_plot = function(x)
  {
    if(x.options.renderer == "canvas" && _this.renderer.GL)
    {
      _this.renderer = new THREE.CanvasRenderer();
      _this.renderer.GL = false;
      _this.el.appendChild(_this.renderer.domElement);
    }
    var group = new THREE.Object3D();        // contains non-point plot elements (axes, etc.)
    _this.pointgroup = new THREE.Object3D(); // contains plot points
    _this.linegroup = new THREE.Object3D();  // contains plot lines
    group.name = "group";
    _this.pointgroup.name = "pointgroup";
    _this.linegroup.name = "linegroup";
    scene.add(group);
    scene.add(_this.linegroup);
    scene.add(_this.pointgroup);
    if(x.bg) _this.renderer.setClearColor(new THREE.Color(x.bg));
    if(x.options.top) _this.infobox.style.top = x.options.top;
    if(x.options.left) _this.infobox.style.left = x.options.left;
    if(x.options.fontmain) _this.infobox.style.font = x.options.fontmain;
    if(Array.isArray(x.options.main))
    {
      _this.main = x.options.main[0];
      _this.mains = x.options.main;
    } else if(x.options.main) _this.main = x.options.main;
    printInfo(_this.main);
    if(x.options.mousethreshold) _this.mousethreshold = x.options.mousethreshold;
    var cexaxis = 0.5;
    var cexlab = 1;
    var fontaxis = "48px Arial";
    var fontsymbols = "48px Arial";
    if(x.options.cexaxis) cexaxis = parseFloat(x.options.cexaxis);
    if(x.options.cexlab) cexlab = parseFloat(x.options.cexlab);
    if(x.options.fontaxis) fontaxis = x.options.fontaxis;
    if(x.options.fontsymbols) fontsymbols = x.options.fontsymbols;

    // circle sprite for pch='@'
    var sz = 512;
    var dataColor = new Uint8Array( sz * sz * 4 );
    for(var i = 0; i < sz * sz * 4; i++) dataColor[i] = 0;
    for(var i = 0; i < sz; i++)
    {
      for(var j = 0; j < sz; j++)
      {
        var dx = 2*i/(sz-1) - 1;
        var dy = 2*j/(sz-1) - 1;
        var dz = dx*dx + dy*dy;
        var k = i*sz + j;
        if(dz <= 0.75)
        {
          dataColor[k*4] = 255;
          dataColor[k*4 + 1] = 255;
          dataColor[k*4 + 2] = 255;
          dataColor[k*4 + 3] = 255;
        } else if(dz < 1)
        {
          dataColor[k*4] = 0;
          dataColor[k*4 + 1] = 0;
          dataColor[k*4 + 2] = 0;
          dataColor[k*4 + 3] = 255;
        }
      }
    }
    var circle = new THREE.DataTexture(dataColor, sz, sz, THREE.RGBAFormat, THREE.UnsignedByteType );
    circle.needsUpdate = true;
    // circle sprite for pch='.'
    var sz = 16;
    var dataColor = new Uint8Array( sz * sz * 4 );
    for(var i = 0; i < sz * sz * 4; i++) dataColor[i] = 255;
    var square = new THREE.DataTexture(dataColor, sz, sz, THREE.RGBAFormat, THREE.UnsignedByteType );
    square.needsUpdate = true;


    if(_this.renderer.GL)
    {
      _this.N = x.data.length / 3;              // number of vertices
      if(x.options.positions)
      {
        _this.positions = x.options.positions;  // vertex positions array, multiple of _this.N
        _this.data = x.data;                    // copy of scene vertex positions
      } else _this.positions = [];
      if(x.options.nframes)
      {
        _this.nframes = x.options.nframes;      // total frames
        _this.frame = 0;
      }
      if(x.options.fromlist)
      {
        _this.fromlist = x.options.fromlist;   // animated edges changing on each extra scene
        _this.tolist = x.options.tolist;
        if(x.options.lcollist) _this.lcollist = x.options.lcollist;
      }
      // lights
      /* FIXME add user-defined lights */
      light = new THREE.DirectionalLight(0xffffff);
      light.position.set(1, 1, 1);
      scene.add(light);
      light = new THREE.DirectionalLight(0x002255);
      light.position.set(-1, -1, -1);
      scene.add(light);
      light = new THREE.AmbientLight(0x444444);
      scene.add(light );

      // Handle mupltiple kinds of glyphs
      /* FIXME avoid multiple data scans here and below (pre-sort by pch, for instance) */
      var npoints = 0;
      var scale = 0.02;
      for ( var i = 0; i < x.data.length / 3; i++)
      {
        if(x.options.pch[i] == 'o')    // special case: spheres
        {
          npoints++;
          if(x.options.size) {
            if(Array.isArray(x.options.size)) scale = 0.02 * x.options.size[i];
            else scale = 0.02 * x.options.size;
          }
          // Create geometry
          var sphereGeo =  new THREE.SphereGeometry(scale, 20, 20);
          sphereGeo.computeFaceNormals();
          // Move to position
          sphereGeo.applyMatrix (new THREE.Matrix4().makeTranslation(x.data[i*3], x.data[i*3 + 1], x.data[i*3 + 2]));
          // Color
          if(x.options.color) {
            if(Array.isArray(x.options.color)) col = new THREE.Color(x.options.color[i]);
            else col = new THREE.Color(x.options.color);
          }
          else col = new THREE.Color("steelblue");
        /** FIXME: Performance can be improved if the geometries are merged.
         * http://learningthreejs.com/blog/2011/10/05/performance-merging-geometry/
         */
          // ADD
          var mesh = new THREE.Mesh(sphereGeo, new THREE.MeshLambertMaterial({color : col}));
          mesh.index = i;
          if(x.options.labels && Array.isArray(x.options.labels)) mesh.label = x.options.labels[i];
          else mesh.label = "";
          _this.pointgroup.add(mesh);
        }
      } // end of special sphere case
      if(npoints < x.data.length / 3)
      { // more points to draw
        var unique_pch = [...new Set(x.options.pch)];
        if(!Array.isArray(x.options.pch)) unique_pch = [...new Set([x.options.pch])];

        for(var j=0; j < unique_pch.length; j++)
        {
          npoints = 0;
          for (var i = 0; i < x.data.length / 3; i++)
          {
            if(x.options.pch[i] == unique_pch[j]) npoints++;
          }
          var geometry = new THREE.BufferGeometry();
          var positions = new Float32Array(npoints * 3);
          var colors = new Float32Array(npoints * 4);
          var sizes = new Float32Array(npoints);
          var col = new THREE.Color("steelblue");
          scale = 0.3;

          // generic pch sprite (text)
          var canvas = document.createElement('canvas');
          var cwidth = 512;
          canvas.width = cwidth;
          canvas.height = cwidth;
          var context = canvas.getContext('2d');
          context.fillStyle = "#ffffff";
          context.textAlign = 'center';
          context.textBaseline = 'middle';
          context.font = fontsymbols;
          context.fillText(unique_pch[j], cwidth / 2, cwidth / 2);
          var sprite = new THREE.Texture(canvas);
          sprite.flipY = false;
          sprite.needsUpdate = true;

          geometry.labels = [];

          var txtur, scalefactor;
          if(unique_pch[j] == '@') {
            txtur = circle;
            scalefactor = 0.25;
          } else if(unique_pch[j] == '.') {
            txtur = square;
            scalefactor = 0.25;
          } else {
            txtur = sprite;
            scalefactor = 10;
          }

          if(x.options.size && !Array.isArray(x.options.size)) scale = x.options.size;
          var k = 0;
          for (var i = 0; i < x.data.length / 3; i++)
          {
            if(Array.isArray(x.options.size)) sizes[i] = x.options.size[i] * scalefactor;
            else sizes[i] = scale * scalefactor;
            if(x.options.pch[i] == unique_pch[j])
            {
              if(x.options.labels && Array.isArray(x.options.labels)) geometry.labels.push(x.options.labels[i]);
              else geometry.labels.push("");
              positions[k * 3 ] = x.data[i * 3];
              positions[k * 3 + 1 ] = x.data[i * 3 + 1];
              positions[k * 3 + 2 ] = x.data[i * 3 + 2];
              if(x.options.color) {
                if(Array.isArray(x.options.color)) col = new THREE.Color(x.options.color[i]);
                else col = new THREE.Color(x.options.color);
              }
              colors[k * 4] = col.r;
              colors[k * 4 + 1] = col.g;
              colors[k * 4 + 2] = col.b;
              if(x.options.alpha && Array.isArray(x.options.alpha)) colors[k * 4 + 3] = x.options.alpha[k];
              else colors[k * 4 + 3] = 1;
              k++;
            }
          }
          geometry.addAttribute('position', new THREE.BufferAttribute(positions, 3));
          geometry.addAttribute('color', new THREE.BufferAttribute(colors, 4));
          geometry.addAttribute('size', new THREE.BufferAttribute(sizes, 1));
          geometry.computeBoundingSphere();
          var material = new THREE.ShaderMaterial({
              uniforms: {
                ucolor:   { value: new THREE.Color( 0xffffff ) },
                texture: { value: txtur }
              },
              vertexShader: "attribute float size; attribute vec4 color; varying vec4 vColor; void main() { vColor = color; vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 ); gl_PointSize = size * ( 300.0 / -mvPosition.z ); gl_Position = projectionMatrix * mvPosition; }",
              fragmentShader: "uniform sampler2D texture; varying vec4 vColor; void main() { gl_FragColor = vec4( vColor ); gl_FragColor = gl_FragColor * texture2D( texture, gl_PointCoord ); if ( gl_FragColor.a < ALPHATEST ) discard; }",
              alphaTest: 0.1    // mapped by threejs to "ALPHATEST" in shader :(
          });
          var particleSystem = new THREE.Points(geometry, material);
          _this.pointgroup.add(particleSystem);
        }
      }
    } else { // canvas (not WebGL)
      var program = function (context)
      {
        context.beginPath();
        context.arc(0, 0, 0.5, 0, Math.PI*2, true);
        if(x.options.stroke)
        { 
          context.strokeStyle = x.options.stroke;
          context.lineWidth = 0.15;
          context.stroke();
        }
        context.fill();
      };
      var col = new THREE.Color("steelblue");
      var scale = 0.03;
      for ( var i = 0; i < x.data.length / 3; i++ ) {
        if(x.options.color) {
          if(Array.isArray(x.options.color)) col = new THREE.Color(x.options.color[i]);
          else col = new THREE.Color(x.options.color);
        }
        if(x.options.size) {
          if(Array.isArray(x.options.size)) scale = 0.03 * x.options.size[i];
          else scale = 0.03 * x.options.size;
        }
        var material = new THREE.SpriteCanvasMaterial( {
            color: col, program: program , opacity:0.9} );
        var particle = new THREE.Sprite(material);
        particle.position.x = x.data[i * 3];
        particle.position.y = x.data[i* 3 + 1];
        particle.position.z = x.data[i * 3 + 2];
        particle.scale.x = particle.scale.y = scale;
        _this.pointgroup.add(particle);
      }
    }

// helper function to add text to 'object'
    function addText(object, string, scale, x, y, z, color)
    {
      var canvas = document.createElement('canvas');
      var context = canvas.getContext('2d');
      scale = scale / 4;
      context.fillStyle = "#" + color.getHexString();
      context.textAlign = 'center';
      context.font = fontaxis;
      var size = Math.max(64, Math.pow(2, Math.ceil(Math.log2(context.measureText(string).width))));
      canvas.width = size;
      canvas.height = size;
      scale = scale * (size / 128);
      context = canvas.getContext('2d');
      context.fillStyle = "#" + color.getHexString();
      context.textAlign = 'center';
      context.textBaseline = 'middle';
      context.font = fontaxis;
      context.fillText(string, size / 2, size / 2);
      var amap = new THREE.Texture(canvas);
      amap.needsUpdate = true;
      var mat = new THREE.SpriteMaterial({
        map: amap,
        transparent: true,
        color: 0xffffff });
      sp = new THREE.Sprite(mat);
      sp.scale.set( scale, scale, scale );
      sp.position.x = x;
      sp.position.y = y;
      sp.position.z = z;
      object.add(sp);
    }

// Set up the axes
    var axisColor = new THREE.Color("#000000");
    if(x.bg)
    {
      var bgcolor = new THREE.Color(x.bg);
      axisColor.r = 1 - bgcolor.r;
      axisColor.g = 1 - bgcolor.g;
      axisColor.b = 1 - bgcolor.b;
      _this.fgcss = "#" + axisColor.getHexString(); // mouse-over info box color
      _this.infobox.style.color = _this.fgcss;
    }
    function v(x,y,z){ return new THREE.Vector3(x,y,z); }
    var tickColor = axisColor;
    tickColor.r = Math.min(tickColor.r + 0.2, 1);
    tickColor.g = Math.min(tickColor.g + 0.2, 1);
    tickColor.b = Math.min(tickColor.b + 0.2, 1);

    if(x.options.axis)
    {
      var xAxisGeo = new THREE.Geometry();
      var yAxisGeo = new THREE.Geometry();
      var zAxisGeo = new THREE.Geometry();
      xAxisGeo.vertices.push(v(0, 0, 0), v(1, 0, 0));
      yAxisGeo.vertices.push(v(0, 0, 0), v(0, 1, 0));
      zAxisGeo.vertices.push(v(0, 0, 0), v(0, 0, 1));
      var xAxis = new THREE.Line(xAxisGeo, new THREE.LineBasicMaterial({color: axisColor, linewidth: 1}));
      var yAxis = new THREE.Line(yAxisGeo, new THREE.LineBasicMaterial({color: axisColor, linewidth: 1}));
      var zAxis = new THREE.Line(zAxisGeo, new THREE.LineBasicMaterial({color: axisColor, linewidth: 1}));
      xAxis.type = THREE.Lines;
      yAxis.type = THREE.Lines;
      zAxis.type = THREE.Lines;
      group.add(xAxis);
      group.add(yAxis);
      group.add(zAxis);
      if(x.options.axisLabels)
      {
        addText(group, x.options.axisLabels[0], cexlab, 1.1, 0, 0, axisColor)
        addText(group, x.options.axisLabels[1], cexlab, 0, 1.1, 0, axisColor)
        addText(group, x.options.axisLabels[2], cexlab, 0, 0, 1.1, axisColor)
      }
// Ticks and tick labels
      function tick(length, thickness, axis, ticks, ticklabels)
      { 
        for(var j=0; j<ticks.length; j++)
        {
          var tick = new THREE.Geometry();
          var a1 = ticks[j]; var a2 = ticks[j]; var a3=ticks[j];
          var b1 = length; var b2 = -length; var b3=-0.05;
          var c1 = 0; var c2 = 0; var c3=-0.08;
          if(axis==1){a1=length; b1=ticks[j]; c1=0; a2=-length; b2=ticks[j]; c2=0; a3=0.08; b3=ticks[j]; c3=-0.05;}
          else if(axis==2){a1=0; b1=length; c1=ticks[j];a2=0;b2=-length;c2=ticks[j]; a3=-0.08; b3=-0.05; c3=ticks[j];}
          tick.vertices.push(v(a1,b1,c1),v(a2,b2,c2));
          if(ticklabels)
            addText(group, ticklabels[j], cexaxis, a3, b3, c3, tickColor);
          var tl = new THREE.Line(tick, new THREE.LineBasicMaterial({color: tickColor, linewidth: thickness}));
          tl.type=THREE.Lines;
          group.add(tl);
        }
      }
      if(x.options.xtick) tick(0.005,3,0,x.options.xtick,x.options.xticklab);
      if(x.options.ytick) tick(0.005,3,1,x.options.ytick,x.options.yticklab);
      if(x.options.ztick) tick(0.005,3,2,x.options.ztick,x.options.zticklab);
    }

// Grid
    if(x.options.grid && x.options.xtick && x.options.ztick && x.options.xtick.length==x.options.ztick.length)
    { 
      for(var j=1; j<x.options.xtick.length; j++)
      {
        var gridline = new THREE.Geometry();
        gridline.vertices.push(v(x.options.xtick[j],0,0),v(x.options.xtick[j],0,1));
        var gl = new THREE.Line(gridline, new THREE.LineBasicMaterial({color: tickColor, linewidth: 1}));
        gl.type = THREE.Lines;
        group.add(gl);
        gridline = new THREE.Geometry();
        gridline.vertices.push(v(0, 0, x.options.ztick[j]), v(1, 0, x.options.ztick[j]));
        gl = new THREE.Line(gridline, new THREE.LineBasicMaterial({color: tickColor, linewidth: 1}));
        gl.type=THREE.Lines;
        group.add(gl);
      }
    }

// Lines
/* Note that variable line widths are not directly supported by buffered geometry, see for instance:
 * http://stackoverflow.com/questions/32544413/buffergeometry-and-linebasicmaterial-segments-thickness
 * If lwd is an array then need use non-buffered geometry (slow), otherwise buffer.
 **FIXME add custom shader to support this!
 */
    if(x.options.from && _this.renderer.GL)
    {
      if(Array.isArray(x.options.lwd))
      {
        if(!x.options.lcol) x.options.lcol = "#aaaaaa";
        for(var j=0; j < x.options.from.length; j++)
        {
          var gridline = new THREE.Geometry();
          gridline.vertices.push(
            v(x.data[3 * x.options.from[j]],
              x.data[3 * x.options.from[j] + 1],
              x.data[3 * x.options.from[j] + 2]),
            v(x.data[3 * x.options.to[j]],
              x.data[3 * x.options.to[j] + 1],
              x.data[3 * x.options.to[j] + 2]));


// custom shader here for line width FIXME


          if(Array.isArray(x.options.lcol))
            var gl = new THREE.Line(gridline, new THREE.LineBasicMaterial({color: x.options.lcol[j], linewidth: x.options.lwd[j], opacity: x.options.linealpha, transparent: true}));
          else
            var gl = new THREE.Line(gridline, new THREE.LineBasicMaterial({color: x.options.lcol, linewidth: x.options.lwd[j], opacity: x.options.linealpha, transparent: true}));
          group.add(gl);
        }
      } else // use buffered geometry
      {
        _this.data = x.data;
        _this.from = x.options.from; // store these for future use in animation, see update()
        _this.to = x.options.to;
        _this.color = x.options.color;
        if(x.options.lcol) _this.lcol = x.options.lcol;
        _this.lwd = x.options.lwd;
        _this.linealpha = x.options.linealpha;
        update_lines(true);
      }
    }

    _this.idle = false;
    render();
  }

/** FIXME There is probably a better/more efficient threejs way to animate, help appreciated */
  _this.update = function() // XXX TESTING
  {
    /* _this.N number of vertices
     * _this.nframes total number of frames
     * _this.positions vertex points in each scene
     * For instance:
     * _this.N = 50,
     * _this.positions = 150 (three scenes after the initial one in x.data, total of four),
     * _this.nframes = 30 (ten interpolated frames per scene)
     */
    var nscenes = _this.positions.length / (3 * _this.N);    // number of scenes beyond initial scene
    var idx = nscenes * (_this.frame  / _this.nframes);
    var fidx = Math.floor(idx);
    if(idx == fidx)
    {
      if(_this.mains)
      {
        _this.main = _this.mains[idx];  // update title
        printInfo(_this.main);
      }
      if(_this.lcollist && idx > 0) _this.lcol = _this.lcollist[idx - 1]; // update edge colors maybe
      if(_this.fromlist && idx > 0)
      {
        _this.from = _this.fromlist[idx - 1]; // update edges
        _this.to = _this.tolist[idx - 1];     // update edges
        update_lines(false);
      }
    }
    if(_this.frame >= _this.nframes)
    {
       _this.frame = -1;
    }
    if(_this.frame > -1)
    {
      var fps = _this.nframes / nscenes;
      var scene = Math.floor(nscenes * (_this.frame  / _this.nframes));
      var edgeidx = (nscenes * (_this.frame + 1) / _this.nframes);
      var interp = fps - _this.frame % fps;
      var k = 0; // vertex id
      _this.frame = _this.frame + 1;
      for(var j = 0; j < _this.pointgroup.children.length; j++)
      {
        var m = scene * _this.N * 3;
        if(_this.pointgroup.children[j].type == "Mesh")
        {
          var x = _this.data[k * 3];
          var y = _this.data[k * 3 + 1];
          var z = _this.data[k * 3 + 2];
          var x1 = _this.positions[m + k*3];
          var y1 = _this.positions[m + k*3 + 1];
          var z1 = _this.positions[m + k*3 + 2];
          var dx = (x1 - x) / interp;
          var dy = (y1 - y) / interp;
          var dz = (z1 - z) / interp;
          // update for convenient lookup in LinesSegments below
          _this.data[k * 3] = _this.data[k * 3] + dx;
          _this.data[k * 3 + 1] = _this.data[k * 3 + 1] + dy;
          _this.data[k * 3 + 2] = _this.data[k * 3 + 2] + dz;
          _this.pointgroup.children[j].geometry.translate(dx, dy, dz);
          k++;
        } else if(_this.pointgroup.children[j].type == "Points") // Buffered
        {
          for(var i = 0; i < _this.pointgroup.children[j].geometry.attributes.position.array.length / 3; i++)
          {
            var x = _this.pointgroup.children[j].geometry.attributes.position.array[i * 3];
            var y = _this.pointgroup.children[j].geometry.attributes.position.array[i * 3 + 1];
            var z = _this.pointgroup.children[j].geometry.attributes.position.array[i * 3 + 2];
            var x1 = _this.positions[m + k*3];
            var y1 = _this.positions[m + k*3 + 1];
            var z1 = _this.positions[m + k*3 + 2];
            _this.pointgroup.children[j].geometry.attributes.position.array[i * 3] = 
              _this.pointgroup.children[j].geometry.attributes.position.array[i * 3] +
              (x1 - x) / interp;
            _this.pointgroup.children[j].geometry.attributes.position.array[i * 3 + 1] = 
              _this.pointgroup.children[j].geometry.attributes.position.array[i * 3 + 1] +
              (y1 - y) / interp;
            _this.pointgroup.children[j].geometry.attributes.position.array[i * 3 + 2] = 
              _this.pointgroup.children[j].geometry.attributes.position.array[i * 3 + 2] +
              (z1 - z) / interp;
            // update for convenient lookup in LinesSegments below
            _this.data[k*3] = _this.pointgroup.children[j].geometry.attributes.position.array[i * 3];
            _this.data[k*3 + 1] = _this.pointgroup.children[j].geometry.attributes.position.array[i * 3 + 1];
            _this.data[k*3 + 2] = _this.pointgroup.children[j].geometry.attributes.position.array[i * 3 + 2];
            k++;
          }
          _this.pointgroup.children[j].geometry.attributes.position.needsUpdate = true;
        }
      }
      update_lines(false);
    }
  }

  function update_lines(init)
  {
    if(init || _this.linegroup.children.length > 0) // Buffered line segments (replace)
    {
      var segments = _this.from.length;
      var geometry = new THREE.BufferGeometry();
      var positions = new Float32Array(segments * 6);
      var colors = new Float32Array(segments * 6);
      for(var i = 0; i < _this.from.length; i++)
      {
        var from = _this.from[i];
        var to = _this.to[i];
        var c1, c2;
        if(_this.lcol)
        {
          if(Array.isArray(_this.lcol))
            c1 = new THREE.Color(_this.lcol[i]);
          else
            c1 = new THREE.Color(_this.lcol);
          c2 = c1;
        } else
        {
          if(Array.isArray(_this.color))
          {
            c1 = new THREE.Color(_this.color[from]);
            c2 = new THREE.Color(_this.color[to]);
          } else
          {
            c1 = new THREE.Color(_this.color);
            c2 = c1;
          }
        }
        colors[i * 6] = c1.r;
        colors[i * 6 + 1] = c1.g;
        colors[i * 6 + 2] = c1.b;
        colors[i * 6 + 3] = c2.r;
        colors[i * 6 + 4] = c2.g;
        colors[i * 6 + 5] = c2.b;
        positions[i * 6] = _this.data[from * 3];
        positions[i * 6 + 1] = _this.data[from * 3 + 1];
        positions[i * 6 + 2] = _this.data[from * 3 + 2];
        positions[i * 6 + 3] = _this.data[to * 3];
        positions[i * 6 + 4] = _this.data[to * 3 + 1];
        positions[i * 6 + 5] = _this.data[to * 3 + 2];
      }
      geometry.addAttribute('position', new THREE.BufferAttribute(positions, 3));
      geometry.addAttribute('color', new THREE.BufferAttribute(colors, 3));
      geometry.computeBoundingSphere();
      if(init)
      {
        var material = new THREE.LineBasicMaterial({vertexColors: THREE.VertexColors, linewidth: _this.lwd, opacity: _this.linealpha, transparent: true});
        var lines = new THREE.LineSegments(geometry, material);
        _this.linegroup.add(lines);
      } else
      {
        _this.linegroup.children[0].geometry = geometry;
        _this.linegroup.children[0].geometry.attributes.position.needsUpdate = true;
      }
    }
  }

  function printInfo(text)
  {
    if(_this.infobox.innerHTML != text)
    {
      _this.infobox.innerHTML = text;
      _this.infobox.style.color = _this.fgcss;
    }
  }

  _this.animate = function ()
  {
    controls.update();
    render();
    _this.update();
    if(! _this.idle)  requestAnimationFrame(_this.animate); // (hogs CPU)
  };

  function render()
  {
    if(controls.idle && _this.frame < 0) _this.idle = true; // Conserve CPU by terminating render loop when not needed
    // render scenes
    _this.renderer.clear();
    _this.renderer.render(scene, camera);
  }

};
