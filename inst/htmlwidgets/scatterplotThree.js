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
 * reset()
 * animate()
 */
var Widget = Widget || {};
Widget.scatter = function()
{
//  var options = options || {};
  this.show_title = true;
  this.show_labels = false;
  this.idle = true;

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

    el.onmousemove = function(ev)
    { 
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
    controls.dynamicDampingFactor = 0.3;
    controls.addEventListener( 'change', render );

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
    var group = new THREE.Object3D();      // contains non-point plot elements
    var pointgroup = new THREE.Object3D(); // contains point elements
    group.name = "group";
    pointgroup.name = "pointgroup";
    scene.add( group );
    scene.add( pointgroup );
    if(x.bg) _this.renderer.setClearColor(new THREE.Color(x.bg));

    if(_this.renderer.GL)
    {
      // lights
      light = new THREE.DirectionalLight( 0xffffff );
      light.position.set( 1, 1, 1 );
      scene.add( light );
      light = new THREE.DirectionalLight( 0x002288 );
      light.position.set( -1, -1, -1 );
      scene.add( light );
      light = new THREE.AmbientLight( 0x222222 );
      scene.add( light );
      // Handle spheres (pch == 'o')
      if(x.options.pch == 'o')
      {
        for ( var i = 0; i < x.data.length / 3; i++)
        {
          var scale = 0.02;
          if(x.options.size) {
            if(Array.isArray(x.options.size)) scale = 0.02 * x.options.size[i];
            else scale = 0.02 * x.options.size;
          }
          // Create geometry
          var sphereGeo =  new THREE.SphereGeometry(scale, 20, 20);
          sphereGeo.computeFaceNormals();
          // Move to position
          sphereGeo.applyMatrix ( new THREE.Matrix4().makeTranslation(x.data[i*3 ],x.data[i*3 + 1] , x.data[i*3 + 2]) );
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
             pointgroup.add(mesh);
        }
      }
      else // add buffered geometry glyphs (pch != 'o')
      {
        var npoints = x.data.length / 3;
        var geometry = new THREE.BufferGeometry();
        var positions = new Float32Array( npoints * 3 ); // need a typed array, forces a data copy
        var colors = new Float32Array( npoints * 3 );
        var col = new THREE.Color("steelblue");
        var scale = 0.3;

        var canvas = document.createElement('canvas');
        var csz = 64;
        canvas.width = csz;
        canvas.height = csz;
        var context = canvas.getContext('2d');
        context.fillStyle = "#ffffff";
        context.textAlign = 'center';
        context.font = '16px Arial';
        context.fillText(x.options.pch, csz/2, csz/2);
        var sprite = new THREE.Texture(canvas);
        sprite.needsUpdate = true;

        if(x.options.size && !Array.isArray(x.options.size)) scale = 0.3 * x.options.size;
        for (var i = 0; i < x.data.length / 3; i++)
        {
          positions[i * 3 ] = x.data[i * 3];
          positions[i * 3 + 1 ] = x.data[i * 3 + 1];
          positions[i * 3 + 2 ] = x.data[i * 3 + 2];
          if(x.options.color) {
            if(Array.isArray(x.options.color)) col = new THREE.Color(x.options.color[i]);
            else col = new THREE.Color(x.options.color);
          }
          colors[i * 3] = col.r;
          colors[i * 3 + 1] = col.g;
          colors[i * 3 + 2] = col.b;
        }
        geometry.addAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.addAttribute('color', new THREE.BufferAttribute(colors, 3));
        geometry.computeBoundingSphere();
        var material;
        if(x.options.pch == '.')  // most efficient glyph
        {
          material = new THREE.PointsMaterial({size: scale / 20, transparent: true, alphaTest: 0.5, vertexColors: THREE.VertexColors});
        } else
        {
          material = new THREE.PointsMaterial({size: scale, map: sprite, transparent: true, alphaTest: 0.5, vertexColors: THREE.VertexColors});
        }
        var particleSystem = new THREE.Points(geometry, material);
        pointgroup.add(particleSystem);
      }
    } else { // canvas (not WebGL)
      var program = function ( context )
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
        var particle = new THREE.Sprite( material );
        particle.position.x = x.data[i * 3];
        particle.position.y = x.data[i* 3 + 1];
        particle.position.z = x.data[i * 3 + 2];
        particle.scale.x = particle.scale.y = scale;
        // Label points.
        if(x.options.labels)
        {
          if(Array.isArray(x.options.labels)) particle.name = x.options.labels[i];
          else particle.name = x.options.labels;
        }
        pointgroup.add( particle );
      }
    }

// helper function to add text to 'object'
    function addText(object, string, scale, x, y, z, color)
    {
      var canvas = document.createElement('canvas');
      var size = 256;
      canvas.width = size;
      canvas.height = size;
      var context = canvas.getContext('2d');
      context.fillStyle = "#" + color.getHexString();
      context.textAlign = 'center';
      context.font = '24px Arial';
      context.fillText(string, size / 2, size / 2);
      var amap = new THREE.Texture(canvas);
      amap.needsUpdate = true;
      var mat = new THREE.SpriteMaterial({
        map: amap,
        transparent: true,
//        useScreenCoordinates: false,
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
    }

    var fontSize = Math.max(Math.round(1/4), 8);
    var fontOffset = Math.min(Math.round(fontSize/4), 8);
    var xAxisGeo = new THREE.Geometry();
    var yAxisGeo = new THREE.Geometry();
    var zAxisGeo = new THREE.Geometry();
    function v(x,y,z){ return new THREE.Vector3(x,y,z); }
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
      addText(group, x.options.axisLabels[0], 0.8, 1.1, 0, 0, axisColor)
      addText(group, x.options.axisLabels[1], 0.8, 0, 1.1, 0, axisColor)
      addText(group, x.options.axisLabels[2], 0.8, 0, 0, 1.1, axisColor)
    }
// Ticks and tick labels
    var tickColor = axisColor;
    tickColor.r = Math.min(tickColor.r + 0.2, 1);
    tickColor.g = Math.min(tickColor.g + 0.2, 1);
    tickColor.b = Math.min(tickColor.b + 0.2, 1);
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
          addText(group, ticklabels[j], 0.5, a3, b3, c3, tickColor);
        var tl = new THREE.Line(tick, new THREE.LineBasicMaterial({color: tickColor, linewidth: thickness}));
        tl.type=THREE.Lines;
        group.add(tl);
      }
    }
    if(x.options.xtick) tick(0.005,3,0,x.options.xtick,x.options.xticklab);
    if(x.options.ytick) tick(0.005,3,1,x.options.ytick,x.options.yticklab);
    if(x.options.ztick) tick(0.005,3,2,x.options.ztick,x.options.zticklab);
// Grid
    if(x.options.grid && x.options.xtick && x.options.ztick && x.options.xtick.length==x.options.ztick.length)
    { 
      for(var j=1; j<x.options.xtick.length; j++)
      {
        var gridline = new THREE.Geometry();
        gridline.vertices.push(v(x.options.xtick[j],0,0),v(x.options.xtick[j],0,1));
        var gl = new THREE.Line(gridline, new THREE.LineBasicMaterial({color: tickColor, linewidth: 1}));
        gl.type=THREE.Lines;
        group.add(gl);
        gridline = new THREE.Geometry();
        gridline.vertices.push(v(0,0,x.options.ztick[j]),v(1,0,x.options.ztick[j]));
        gl = new THREE.Line(gridline, new THREE.LineBasicMaterial({color: tickColor, linewidth: 1}));
        gl.type=THREE.Lines;
        group.add(gl);
      }
    }

    _this.idle = false;
    render();
  }

  _this.reset = function()
  {
    controls.reset();
    if(_this.idle)
    { 
      _this.idle = false;
      _this.animate();
    }

  }

  _this.animate = function ()
  {
    controls.update();
    render();
    if(! _this.idle)  requestAnimationFrame(_this.animate); // (hogs CPU)
  };

  function render()
  {
    if(controls.idle) _this.idle = true; // Conserve CPU by terminating render loop when not needed
    // render scenes
    _this.renderer.clear();
    _this.renderer.render(scene, camera);
  }

};
