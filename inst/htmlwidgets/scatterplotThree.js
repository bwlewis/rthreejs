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
  this.show_title = true;
  this.show_labels = false;
  this.idle = true;
  this.frame = 1;

  var camera, controls, scene, scene2; // two scenes for fine control of displayed z order
  var _this = this;
HOMER=this;

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
    controls.dynamicDampingFactor = 0.2;
    controls.addEventListener('change', render);

    scene = new THREE.Scene();
    scene2 = new THREE.Scene();
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
    var group = new THREE.Object3D();      // contains non-point plot elements (axes, etc.)
    _this.pointgroup = new THREE.Object3D(); // contains plot points and lines
// .children[0].geometry.attributes.position.array
// .children[1].geometry.attributes.position.array
// ... (up to length of unique pch)
// last one is the lines
// .children[0].geometry.attributes.position.needsUpdate = true
    group.name = "group";
    _this.pointgroup.name = "pointgroup";
    scene2.add(group);
    scene.add(_this.pointgroup);
    if(x.bg) _this.renderer.setClearColor(new THREE.Color(x.bg));
    var cexaxis = 0.5;
    var cexlab = 1;
    var fontaxis = "48px Arial";
    var fontsymbols = "32px Arial";
    if(x.options.cexaxis) cexaxis = parseFloat(x.options.cexaxis);
    if(x.options.cexlab) cexlab = parseFloat(x.options.cexlab);
    if(x.options.fontaxis) fontaxis = x.options.fontaxis;
    if(x.options.fontsymbols) fontsymbols = x.options.fontsymbols;

    if(_this.renderer.GL)
    {
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
             _this.pointgroup.add(mesh);
        }
      }
      if(npoints < x.data.length / 3)
      { // more points to draw
        var unique_pch = [...new Set(x.options.pch)];
        if(!Array.isArray(x.options.pch)) unique_pch = [...new Set([x.options.pch])];
        // special sprite for pch='@'
        var sz = 512;
        var dataColor = new Uint8Array( sz * sz * 4 );
        if(x.options.opacity) alpha = alpha * x.options.opacity;
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
        var special = new THREE.DataTexture(dataColor, sz, sz, THREE.RGBAFormat, THREE.UnsignedByteType );
        special.needsUpdate = true;

        for(var j=0; j < unique_pch.length; j++)
        {
          npoints = 0;
          for (var i = 0; i < x.data.length / 3; i++)
          {
            if(x.options.pch[i] == unique_pch[j]) npoints++;
          }
          var geometry = new THREE.BufferGeometry();
          var positions = new Float32Array(npoints * 3);
          var colors = new Float32Array(npoints * 3);
          var col = new THREE.Color("steelblue");
          scale = 0.3;

          // generic pch sprite
          var canvas = document.createElement('canvas');
          var context = canvas.getContext('2d');
          context.fillStyle = "#ffffff";
          context.textAlign = 'center';
          context.textBaseline = 'middle';
          context.font = fontsymbols;
          var pch_size = context.measureText(unique_pch[j]);
          var cwidth = Math.max(64, Math.pow(2, Math.ceil(Math.log2(pch_size.width))));
          var cheight = cwidth;
          canvas.width = cwidth;
          canvas.height = cheight;
          context = canvas.getContext('2d');
          context.fillStyle = "#ffffff";
          context.textAlign = 'center';
          var sprite = new THREE.Texture(canvas);
          sprite.needsUpdate = true;

          if(x.options.size && !Array.isArray(x.options.size)) scale = 0.3 * x.options.size * (cwidth / 64);
          var k = 0;
          for (var i = 0; i < x.data.length / 3; i++)
          {
            if(x.options.pch[i] == unique_pch[j])
            {
              if(x.options.size && Array.isArray(x.options.size)) scale = 0.3 * x.options.size[i] * (cwidth / 64);
              positions[k * 3 ] = x.data[i * 3];
              positions[k * 3 + 1 ] = x.data[i * 3 + 1];
              positions[k * 3 + 2 ] = x.data[i * 3 + 2];
              if(x.options.color) {
                if(Array.isArray(x.options.color)) col = new THREE.Color(x.options.color[i]);
                else col = new THREE.Color(x.options.color);
              }
              colors[k * 3] = col.r;
              colors[k * 3 + 1] = col.g;
              colors[k * 3 + 2] = col.b;
              k++;
            }
          }
          geometry.addAttribute('position', new THREE.BufferAttribute(positions, 3));
          geometry.addAttribute('color', new THREE.BufferAttribute(colors, 3));
          geometry.computeBoundingSphere();
          var material;
          if(unique_pch[j] == '.')  // special case, no glyph -- very efficient
          {
            material = new THREE.PointsMaterial({size: scale/10, transparent: true, alphaTest: 0.2, vertexColors: THREE.VertexColors});
          } else if(unique_pch[j] == '@') // another special case, billboard sprite
          {
            material = new THREE.PointsMaterial({size: scale / 2, map: special, transparent: true, alphaTest: 0.2, vertexColors: THREE.VertexColors});
          } else
          {
            material = new THREE.PointsMaterial({size: scale, map: sprite, transparent: true, alphaTest: 0.2, vertexColors: THREE.VertexColors});
          }
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
        gl.type=THREE.Lines;
        group.add(gl);
        gridline = new THREE.Geometry();
        gridline.vertices.push(v(0,0,x.options.ztick[j]),v(1,0,x.options.ztick[j]));
        gl = new THREE.Line(gridline, new THREE.LineBasicMaterial({color: tickColor, linewidth: 1}));
        gl.type=THREE.Lines;
        group.add(gl);
      }
    }

// Lines
/* Note that variable line widths are not supported by buffered geometry, see for instance:
 * http://stackoverflow.com/questions/32544413/buffergeometry-and-linebasicmaterial-segments-thickness
 * If lwd is an array then need use non-buffered geometry (slow), otherwise buffer.
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
          if(Array.isArray(x.options.lcol))
            var gl = new THREE.Line(gridline, new THREE.LineBasicMaterial({color: x.options.lcol[j], linewidth: x.options.lwd[j]}));
          else
            var gl = new THREE.Line(gridline, new THREE.LineBasicMaterial({color: x.options.lcol, linewidth: x.options.lwd[j]}));
          group.add(gl);
        }
      } else // use buffered geometry
      {
        var segments = x.options.from.length;
        var geometry = new THREE.BufferGeometry();
        var material = new THREE.LineBasicMaterial({vertexColors: THREE.VertexColors, linewidth: x.options.lwd});
        var positions = new Float32Array(segments * 6);
        var colors = new Float32Array(segments * 6);
        for(var j=0; j < segments; j++)
        {
          var from = x.options.from[j];
          var to = x.options.to[j];
          var c1, c2;
          if(x.options.lcol)
          {
            if(Array.isArray(x.options.lcol))
              c1 = new THREE.Color(x.options.lcol[j]);
            else
              c1 = new THREE.Color(x.options.lcol);
            c2 = c1;
          } else
          {
            if(Array.isArray(x.options.color))
            {
              c1 = new THREE.Color(x.options.color[from]);
              c2 = new THREE.Color(x.options.color[to]);
            } else
            {
              c1 = new THREE.Color(x.options.color);
              c2 = c1;
            }
          }
          positions[j * 6] = x.data[from * 3];
          positions[j * 6 + 1] = x.data[from * 3 + 1];
          positions[j * 6 + 2] = x.data[from * 3 + 2];
          positions[j * 6 + 3] = x.data[to * 3];
          positions[j * 6 + 4] = x.data[to * 3 + 1];
          positions[j * 6 + 5] = x.data[to * 3 + 2];
          colors[j * 6] = c1.r;
          colors[j * 6 + 1] = c1.g;
          colors[j * 6 + 2] = c1.b;
          colors[j * 6 + 3] = c2.r;
          colors[j * 6 + 4] = c2.g;
          colors[j * 6 + 5] = c2.b;
        }
        geometry.addAttribute('position', new THREE.BufferAttribute(positions, 3));
        geometry.addAttribute('color', new THREE.BufferAttribute(colors, 3));
        geometry.computeBoundingSphere();
        var lines = new THREE.LineSegments(geometry, material);
        _this.pointgroup.add(lines);
      }
    }

    _this.idle = false;
    render();
  }

  _this.update = function() // XXX TEST
  {
    if(_this.frame > 0) _this.frame = 0;
    if(_this.frame > 0)
    {_this.frame = _this.frame + 1;
      for(var j = 0; j < _this.pointgroup.children[0].geometry.attributes.position.array.length; j++)
      _this.pointgroup.children[0].geometry.attributes.position.array[j] =  _this.pointgroup.children[0].geometry.attributes.position.array[j]  + 0.0001;
      _this.pointgroup.children[0].geometry.attributes.position.needsUpdate = true;
    }

// .children[0].geometry.attributes.position.array
// .children[1].geometry.attributes.position.array
// ... (up to length of unique pch)
// last one is the lines
// .children[0].geometry.attributes.position.needsUpdate = true
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
    if(controls.idle && _this.frame < 1) _this.idle = true; // Conserve CPU by terminating render loop when not needed
    // render scenes
    _this.renderer.clear();
    _this.renderer.render(scene2, camera); // non-point elements
    _this.renderer.render(scene, camera);  // points
  }

};
