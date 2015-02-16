/* scatterplotThree.js
 * A set of example Javascript functions that support a threejs-based 3d
 * scatterplot in R, geared for use with the htmlwidgets and shiny packages.
 */
HTMLWidgets.widget(
{

  name: "scatterplotThree",
  type: "output",

  initialize: function(el, width, height)
  {
    var r = render_init(el, width, height, false);
    var c = new THREE.PerspectiveCamera(39, r.domElement.width/r.domElement.height, 1E-5, 10);
    var s = new THREE.Scene();
    return {renderer:r, camera:c, scene: s, width: parseInt(width), height: parseInt(height)};
  },

  resize: function(el, width, height, stuff)
  {
    stuff.renderer.clear();
    stuff.renderer.setSize(parseInt(width), parseInt(height));
    stuff.camera.projectionMatrix = new THREE.Matrix4().makePerspective(stuff.camera.fov,  stuff.renderer.domElement.width/stuff.renderer.domElement.height, stuff.camera.near, stuff.camera.far);
    stuff.camera.lookAt(stuff.scene.position);
    stuff.renderer.render(stuff.scene, stuff.camera);
  },

  renderValue: function(el, x, stuff)
  {
    stuff.renderer = render_init(el, stuff.width, stuff.height, x.options.renderer);
// parse the JSON string from R
    x.data = JSON.parse(x.data);
    scatter(el, x, stuff);
  }
})


function render_init(el, width, height, choice)
{
  var r;
  if(choice=="webgl-buffered") choice = "webgl";
  if(Detector.webgl && (choice=="auto" || choice=="webgl"))
  {
    r = new THREE.WebGLRenderer({antialias: true});
    GL=true;
  } else
  {
    r = new THREE.CanvasRenderer();
    GL=false;
  }
  r.setSize(parseInt(width), parseInt(height));
  r.setClearColor("white");
  d3.select(el).node().style.position = "relative";
  d3.select(el).node().innerHTML="";
  d3.select(el).node().appendChild(r.domElement);
  return r;
}

// x.options list of options including:
// x.options.axisLabels  3 element list of axis labels
// x.options.grid true/false draw xz grid (requires xtick.length==ztick.length)
// x.options.stroke (optional) stroke color (canvas renderer only)
// x.options.color (optional) either a single color or a vector of colors
// x.options.size (optional) either a single size or a vector of sizes
// x.options.renderer, one of "auto" "canvas" "webgl" or "webgl-buffered"
// x.options 
//   xtick:[0,0.5,1]
//   xticklab:["1","2","3"]
//   ytick:[0,0.5,1]
//   yticklab:["10","20","30"]
//   ztick:[0,0.5,1]
//   zticklab:["-1","0","1"]
//   NOTE: ticks must be in [0,1].
// x.data JSON 3-column data matrix. Data are assumed to be already
//   scaled in a unit box (that is, all coordinates are assumed to lie in the
//   interval [0,1]).
// x.hoverLabels optional vector of labels to be shown while hovering
// x.pch.img is an encoded image dataURI used by the WebGL PointCloud renderer only

function scatter(el, x, obj)
{
  obj.camera = new THREE.PerspectiveCamera(39, obj.renderer.domElement.width/obj.renderer.domElement.height, 1E-5, 10);
  obj.camera.position.z = 2;
  obj.camera.position.x = 2.55;
  obj.camera.position.y = 1.25;

  obj.ctrls = new THREE.OrbitControls( obj.camera, el );
  obj.ctrls.damping = 0.2;
  obj.ctrls.addEventListener( 'change', render );

  obj.scene = new THREE.Scene();
  var group = new THREE.Object3D();
  group.name = "group";
  obj.scene.add( group );

  obj.raycaster = new THREE.Raycaster();
  obj.raycaster.params.PointCloud.threshold = 0.005; // FIXME configurable hover threshold

// program for drawing a Canvas point
  var program = function ( context )
  {
    context.beginPath();
    context.arc( 0, 0, 0.5, 0, Math.PI*2, true );
    if(x.options.stroke)
    {
      context.strokeStyle = x.options.stroke;
      context.lineWidth = 0.15;
      context.stroke();
    }
    context.fill();
  };
// add the points
  var j;
  var particles;
  if(x.options.renderer=="webgl-buffered")
  {
    var geometry = new THREE.BufferGeometry();
    var positions = new Float32Array( x.data.length );
    var colors = new Float32Array( x.data.length );
    var col = new THREE.Color("steelblue");
    var scale = 0.07;
    if(x.options.size && !Array.isArray(x.options.size)) scale = 0.07 * x.options.size;
    for ( var i = 0; i < x.data.length; i++ )
    {
      positions[i] = x.data[i];
    }
    for(var i=0;i<x.data.length/3;i++)
    {
      j = i*3;
      if(x.options.color)
      {
        if(Array.isArray(x.options.color)) col = new THREE.Color(x.options.color[i]);
        else col = new THREE.Color(x.options.color);
      }
      colors[j] = col.r;
      colors[j+1] = col.g;
      colors[j+2] = col.b;
    }
    geometry.addAttribute( 'position', new THREE.BufferAttribute( positions, 3 ) );
    geometry.addAttribute( 'color', new THREE.BufferAttribute( colors, 3 ) );
    var pcmaterial = new THREE.PointCloudMaterial( { size: scale, vertexColors: THREE.VertexColors } );
    particles = new THREE.PointCloud( geometry, pcmaterial );
  } else
  {
    var img = document.createElement("img");
    img.src = x.pch.img;
    tex = new THREE.Texture();
    tex.image = img;
    tex.needsUpdate = true;
    var geometry = new THREE.Geometry();
    var colors = [];
    var col = new THREE.Color("steelblue");
    var scale = 0.01;
    if(x.options.size && !Array.isArray(x.options.size)) scale = scale * x.options.size;
    for ( var i = 0; i < x.data.length/3; i++ )
    {
      j = i*3;
      if(x.options.color)
      {
        if(Array.isArray(x.options.color)) col = new THREE.Color(x.options.color[i]);
        else col = new THREE.Color(x.options.color);
      }
      colors[i] = col;
      var vertex = new THREE.Vector3();
      vertex.x = x.data[j];
      vertex.y = x.data[j+1];
      vertex.z = x.data[j+2];
      geometry.vertices.push( vertex );
    }
    geometry.colors = colors;
    var pcmaterial = new THREE.PointCloudMaterial( { map:tex,
        size: scale, vertexColors: THREE.VertexColors, transparent: true, opacity: 0.9} );
    particles = new THREE.PointCloud( geometry, pcmaterial );
    particles.sortParticles = true;
  }
  particles.name = "particles";
  particles.geometry.computeBoundingSphere();
  particles.geometry.computeBoundingBox();
  group.add( particles );

// helper function to add text to object
  function addText(object, string, scale, x, y, z, color)
  {
    var canvas = document.createElement('canvas');
    var size = 256;
    canvas.width = size;
    canvas.height = size;
    var context = canvas.getContext('2d');
    context.fillStyle = color;
    context.textAlign = 'center';
    context.font = '24px Arial';
    context.fillText(string, size / 2, size / 2);
    var amap = new THREE.Texture(canvas);
    amap.needsUpdate = true;
    var mat = new THREE.SpriteMaterial({
      map: amap,
      transparent: true,
      useScreenCoordinates: false,
      color: 0xffffff });
    sp = new THREE.Sprite(mat);
    sp.scale.set( scale, scale, scale );
    sp.position.x = x;
    sp.position.y = y;
    sp.position.z = z;
    object.add(sp);
  }

  function Label( obj )
  {
    this.world = obj;

    this.init = function() {
        var el = document.createElement('div');
        el.style.position = 'absolute';
        //el.style.zIndex = 1;    // if you still don't see the label, try uncommenting this
        el.style.display = "none"; // start hidden
        el.style.className = "hoverLabel";
        this.el = el;
        this.world.renderer.domElement.parentElement.appendChild(this.el);
    };

    this.setPosition = function( pos ) {
        this.position = pos.clone();
        this.updatePosition();
    };

    this.setHtml = function( html ) {
        if ( html != undefined ) {
          this.el.innerHTML = html;
          if ( this.el.style.display == "none" ) {
            this.el.style.display = "";
          }
        } else {
          this.el.style.display = "none";
          this.el.innerHTML = "";
        }
    };

    this.updatePosition = function() {
      var scr = this.position.clone().project( this.world.camera );
      var parentRect = this.el.parentElement.getBoundingClientRect();
      this.el.style.left = ( scr.x + 1 ) * parentRect.width / 2 - this.el.offsetWidth / 2 + 'px';
      this.el.style.top = ( 1 - scr.y ) * parentRect.height / 2 - this.el.offsetHeight - 2 + 'px';
    };

    this.init();
  };

// Set up the axes
  var fontSize = Math.max(Math.round(1/4), 8);
  var fontOffset = Math.min(Math.round(fontSize/4), 8);
  var xAxisGeo = new THREE.Geometry();
  var yAxisGeo = new THREE.Geometry();
  var zAxisGeo = new THREE.Geometry();
  function v(x,y,z){ return new THREE.Vector3(x,y,z); }
  xAxisGeo.vertices.push(v(0, 0, 0), v(1, 0, 0));
  yAxisGeo.vertices.push(v(0, 0, 0), v(0, 1, 0));
  zAxisGeo.vertices.push(v(0, 0, 0), v(0, 0, 1));
  var xAxis = new THREE.Line(xAxisGeo, new THREE.LineBasicMaterial({color: 0x000000, linewidth: 1}));
  var yAxis = new THREE.Line(yAxisGeo, new THREE.LineBasicMaterial({color: 0x000000, linewidth: 1}));
  var zAxis = new THREE.Line(zAxisGeo, new THREE.LineBasicMaterial({color: 0x000000, linewidth: 1}));
  xAxis.type = THREE.Lines;
  yAxis.type = THREE.Lines;
  zAxis.type = THREE.Lines;
  group.add(xAxis);
  group.add(yAxis);
  group.add(zAxis);
  // put the particles to the world's center
  var bbox = group.getObjectByName('particles').geometry.boundingBox;
  group.position.copy( bbox.min.add(bbox.max).multiplyScalar(-0.5) );

  if(x.options.axisLabels)
  {
    addText(group, x.options.axisLabels[0], 0.8, 1.1, 0, 0, "black")
    addText(group, x.options.axisLabels[1], 0.8, 0, 1.1, 0, "black")
    addText(group, x.options.axisLabels[2], 0.8, 0, 0, 1.1, "black")
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
        addText(group, parseFloat(ticklabels[j]).toFixed(1), 0.5, a3, b3, c3, "#555");
      var tl = new THREE.Line(tick, new THREE.LineBasicMaterial({color: 0x000000, linewidth: thickness}));
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
      var gl = new THREE.Line(gridline, new THREE.LineBasicMaterial({color: 0x555555, linewidth: 1}));
      gl.type=THREE.Lines;
      group.add(gl);
      gridline = new THREE.Geometry();
      gridline.vertices.push(v(0,0,x.options.ztick[j]),v(1,0,x.options.ztick[j]));
      gl = new THREE.Line(gridline, new THREE.LineBasicMaterial({color: 0x555555, linewidth: 1}));
      gl.type=THREE.Lines;
      group.add(gl);
    }
  }


  var down = false;
  var lastx = 0, lasty = 0;
  var mouse = new THREE.Vector2();
  var labelsPool = new Array(); // array of hover labels
  var hoverLabels = {}; // currently shown hover labels

  el.onmousedown = function (ev)
  {
    if (ev.which==1) down = true;
  };

  el.onmouseup = function (ev)
  {
    if (ev.which==1) down = false;
  }

  el.onmousemove = function(ev)
  {
    if ( lastx != ev.clientX || lasty != ev.clientY ) {
      // calculate mouse position in normalized device coordinates
      // (-1 to +1) for both components
      var canvasRect = this.getBoundingClientRect();
      mouse.x = 2 * ( ev.pageX - canvasRect.left ) / canvasRect.width - 1;
      mouse.y = -2 * ( ev.pageY - canvasRect.top ) / canvasRect.height + 1;
      lastx = ev.clientX;
      lasty = ev.clientY;

      render();
    }
  };

  // adds hover label for the point
  function setHoverLabel(ptix, html)
  {
    if ( Object.keys(hoverLabels).length >= 10 ) {
        // too many already shown labels, reject
        return;
    }
    hoverLabels[ptix] = labelsPool.length ? labelsPool.pop() : new Label(obj);
    hoverLabels[ptix].setHtml( html );
  }

  // removes hover label from the point
  function removeHoverLabel(ptix)
  {
    var label = hoverLabels[ptix];
    label.setHtml(undefined);
    delete hoverLabels[ptix];
    labelsPool.push(label);
  }

  function updateHoveredLabels()
  {
      var particles = obj.scene.getObjectByName('group').getObjectByName('particles');
      particles.updateMatrixWorld();
      for ( var ptix in hoverLabels ) {
          hoverLabels[ptix].setPosition( particles.geometry.vertices[ptix].clone().applyMatrix4( particles.matrixWorld ) );
      }
  }

  function onMouseHover()
  {
      if ( !x.hoverLabels ) return; // no labels, skip

      // update the picking ray with the camera and mouse position
      // console.log( mouse );
      obj.raycaster.setFromCamera( mouse, obj.camera );

      // calculate objects intersecting the picking ray
      var particles = obj.scene.getObjectByName('group').getObjectByName('particles');
      var intersects = obj.raycaster.intersectObjects( [particles] );
      var curPtIndices = {};
      // add new labels to the points that are being hovered over now
      if ( (intersects.length) > 0 ) {
        for ( var ix in intersects ) {
          var ptix = intersects[ix].index;
          curPtIndices[ptix] = true;
          if ( !(ptix in hoverLabels) ) {
              setHoverLabel( ptix, x.hoverLabels[ptix] );
          }
        }
      }
      // remove tooltips from points that are no longer hovered
      for ( var ptix in hoverLabels ) {
          if ( !(ptix in curPtIndices) ) removeHoverLabel(ptix);
      }
  }

  function render()
  {
    obj.renderer.clear();
 
    obj.camera.updateMatrixWorld();
    if ( !down ) {
      onMouseHover();
      updateHoveredLabels();
    } else {
      for ( var ptix in hoverLabels ) {
        removeHoverLabel(ptix);
      }
    }

    obj.renderer.render(obj.scene, obj.camera);
  }

  render();
// See the note about rendering in the globe.js widget.
}
