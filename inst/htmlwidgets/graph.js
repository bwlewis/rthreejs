/*
 * Adapted from simple_graph.js by David Piegza, see
 * https://github.com/davidpiegza/Graph-Visualization
 * Copyright (c) 2011 David Piegza
 *
 * Implements a simple graph drawing with force-directed placement in 3D.
 *
 */

HTMLWidgets.widget(
{
  name: "graph",
  type: "output",

  initialize: function(el, width, height)
  {
    var g = new Widget.SimpleGraph();
    g.init(el, parseInt(width), parseInt(height));
    return {widget: g, width: parseInt(width), height: parseInt(height)};
  },

  resize: function(el, width, height, obj)
  {
    obj.width = parseInt(width);
    obj.height = parseInt(height);
    obj.widget.renderer.setSize(width, height);
    obj.widget.reset();
  },

  renderValue: function(el, x, obj)
  {
    obj.widget.create_graph(x);
    obj.widget.renderer.setSize(obj.width, obj.height);
    obj.widget.animate(); 
  }
})


/* Define a force-directed graph widget with methods
 * init(el, width, height)
 * create_graph(options)
 * reset()
 * animate()
 */
var Widget = Widget || {};
Widget.SimpleGraph = function()
{
//  var options = options || {};
  this.show_title = true;
  this.show_labels = false;
  this.layout_options = {};
  this.idle = true;

  var camera, controls, scene, object_selection, sprite_map, scene2;
  var info_text = {};
  var graph = new Graph();
geometries = []; // XXX HOMER
  var _this = this;

  _this.init = function (el, width, height)
  {
    _this.renderer = new THREE.WebGLRenderer({alpha: true});
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

    _this.renderer.domElement.addEventListener('dblclick', function(ev) { _this.reset(); }, true);

    camera = new THREE.PerspectiveCamera(40, width/height, 1, 1000000);
    camera.position.z = 5000;

    controls = new THREE.TrackballControls(camera, el);
    controls.rotateSpeed = 0.5;
    controls.zoomSpeed = 5.2;
    controls.panSpeed = 1;
    controls.noZoom = false;
    controls.noPan = false;
    controls.staticMoving = false;
    controls.dynamicDampingFactor = 0.3;
    controls.addEventListener('change', render);

    scene = new THREE.Scene();
    scene2 = new THREE.Scene();

    object_selection = new THREE.ObjectSelection({
      domElement: _this.renderer.domElement,
      controls: controls,
      graph: graph,
      selected: function(obj) {
        if(obj != null) {
          if(typeof(obj.nodeid)=="number") info_text.select = graph.getNode(obj.nodeid).data.title;
        } else {
          delete info_text.select;
        }
      },
      clicked: function(obj) {
      }
    });

    el.appendChild(_this.renderer.domElement);

    // Create title/info box
    if(_this.show_title) {
      var info = document.createElement("div");
      var id_attr = document.createAttribute("id");
      id_attr.nodeValue = "graph-info";
      info.setAttributeNode(id_attr);
      info.style.textAlign = "center";
      info.style.zIndex = 100;
      info.style.fontFamily = "Sans";
      info.style.fontSize = "x-large";
      info.style.position = "relative";
      info.style.color = _this.fgcss;
      info.style.top = 10 - _this.renderer.domElement.height;
      el.appendChild(info);
      _this.infobox = info;
    }
  }

  _this.reset = function()
  {
    controls.reset();
    graph.layout.init();
    if(_this.idle)
    {
      _this.idle = false;
      _this.animate();
    }
  }

  /* create_graph
   * x.nodes a data frame with at least columns id, label, size, color
   * x.edges a data frame with at least columns from, to, size, color
   * x.title a character plot title
   * x.fg foreground text color
   * x.curvature numeric edge curvature (0 for no cuvature)
   * x.showLabels logical if true show node labels
   * x.attraction node graph attraction
   * x.repulsion node graph repulsion
   */
  _this.create_graph = function(x)
  {
    _this.renderer.domElement.style.backgroundColor = x.bg;
    _this.fg = new THREE.Color(x.fg);
    _this.fgcss = x.fg;
    _this.curvature = x.curvature / 2;

    // node sprite with user-supplied stroke color
    var sz = 512;
    var dataColor = new Uint8Array( sz * sz * 4 );
    var stroke = new THREE.Color(x.stroke);
    var alpha = 255 * x.opacity;
    for(var i = 0; i < sz * sz * 4; i++) dataColor[i] = 0;
    for(var i = 0; i < sz; i++)
    {
      for(var j = 0; j < sz; j++)
      {
        var dx = 2*i/(sz-1) - 1;
        var dy = 2*j/(sz-1) - 1;
        var dz = dx*dx + dy*dy;
        var k = i*sz + j;
        if(dz <= 0.85)
        {
          dataColor[k*4] = 255;
          dataColor[k*4 + 1] = 255;
          dataColor[k*4 + 2] = 255;
          dataColor[k*4 + 3] = alpha;
        } else if(dz > 0.85 && dz < 1)
        {
          dataColor[k*4] = Math.floor(stroke.r * 255);
          dataColor[k*4 + 1] = Math.floor(stroke.g * 255);
          dataColor[k*4 + 2] = Math.floor(stroke.b * 255);
          dataColor[k*4 + 3] = alpha;
        }
      }
    }
    sprite_map = new THREE.DataTexture(dataColor, sz, sz, THREE.RGBAFormat, THREE.UnsignedByteType );
    sprite_map.needsUpdate = true;

    for(var j=0; j < x.nodes.length; j++)
    {
      var node = new Node(x.nodes[j].id);
      node.data.title = x.nodes[j].label;
      node.color = new THREE.Color(x.nodes[j].color);
      node.scale = x.nodes[j].size;
      graph.addNode(node);
      drawNode(node);
    }
    for(var j=0; j < x.edges.length; j++)
    {
      var source = graph.getNode(x.edges[j].from);
      var target = graph.getNode(x.edges[j].to);
      graph.addEdge(source, target);
      drawEdge(source, target, new THREE.Color(x.edges[j].color), 2 * x.edges[j].size, x.curvature / 2);
    }

    _this.show_labels = x.showLabels;
    _this.layout_options.width = _this.layout_options.width || 2000;
    _this.layout_options.height = _this.layout_options.height || 2000;
    _this.layout_options.attraction = x.attraction;
    _this.layout_options.repulsion = x.repulsion;
    _this.layout_options.iterations = x.iterations;
    graph.layout = new Layout.ForceDirected(graph, _this.layout_options);
    graph.layout.init();
    info_text.title = x.main;
    _this.idle = false;
  }


  /*
   *  Create a node object and add it to the scene2.
   */
  function drawNode(node)
  {
    var draw_object;
    var draw_scale = 100;
    var smaterial = new THREE.SpriteMaterial({color: node.color, map: sprite_map});
    draw_object = new THREE.Sprite(smaterial);
    draw_object.scale.x = draw_object.scale.y = draw_scale * node.scale;
    var area = 50;
    draw_object.position.x = Math.floor(Math.random() * (area + area + 1) - area);
    draw_object.position.y = Math.floor(Math.random() * (area + area + 1) - area);
    draw_object.position.z = Math.floor(Math.random() * (area + area + 1) - area);
    draw_object.nodeid = node.id;
    node.data.draw_object = draw_object;
    node.position = draw_object.position;
    scene2.add(node.data.draw_object);
  }

  update_edge = function(geo, curvature)
  {
    geo.vertices = [];
    if(curvature > 0)
    {
      var dx = geo.source.data.draw_object.position.x -  geo.target.data.draw_object.position.x;
      var dy = geo.source.data.draw_object.position.y -  geo.target.data.draw_object.position.y;
      var dz = geo.source.data.draw_object.position.z -  geo.target.data.draw_object.position.z;
      var sx = geo.source.data.draw_object.position.x +  geo.target.data.draw_object.position.x;
      var sy = geo.source.data.draw_object.position.y +  geo.target.data.draw_object.position.y;
      var sz = geo.source.data.draw_object.position.z +  geo.target.data.draw_object.position.z;
      var n  = Math.sqrt(geo.source.data.draw_object.position.x * geo.source.data.draw_object.position.x +
                         geo.source.data.draw_object.position.y * geo.source.data.draw_object.position.y +
                         geo.source.data.draw_object.position.z * geo.source.data.draw_object.position.z) +
               Math.sqrt(geo.target.data.draw_object.position.x * geo.target.data.draw_object.position.x +
                         geo.target.data.draw_object.position.y * geo.target.data.draw_object.position.y +
                         geo.target.data.draw_object.position.z * geo.target.data.draw_object.position.z);
      var a  = curvature * Math.sign(geo.source.id - geo.target.id) * Math.sqrt(dx * dx + dy * dy + dz * dz) / n;
      var v = new THREE.Vector3(sx/2, sy/2 + a*sy/2, sz/2 + a*sz/2);
      var curve = new THREE.SplineCurve3([geo.source.data.draw_object.position, v, geo.target.data.draw_object.position]);
      geo.vertices = curve.getPoints(20);
    } else
    {
      geo.vertices.push(geo.source.data.draw_object.position);
      geo.vertices.push(geo.target.data.draw_object.position);
    }
  }

  function drawEdge(source, target, color, size, curvature) {
    var material = new THREE.LineBasicMaterial({ color: color, opacity: 1, linewidth: size });
    var geo = new THREE.Geometry();
    geo.source = source;
    geo.target = target;

    update_edge(geo, curvature);
    var line = new THREE.Line( geo, material );
    line.scale.x = line.scale.y = line.scale.z = 1;
    line.originalScale = 1;
    geometries.push(geo);
    scene.add(line);
  }

  _this.animate = function ()
  {
    controls.update();
    render();
    if(_this.show_title) {
      printInfo(); // XXX why repeat this over and over? Improve...
    }
    if(! _this.idle)  requestAnimationFrame(_this.animate); // Aggressive render loop (hogs CPU)
  };

  function render()
  {
    if(graph.layout.finished && controls.idle)
    {
      _this.idle = true; // Conserve CPU by terminating render loop when not needed
    } else {
      if(!graph.layout.finished)
      {
        // continue layout if not finished
        graph.layout.generate();
      }
    }

    // Update position of lines (edges)
    for(var i=0; i < geometries.length; i++)
    {
      if(_this.curvature > 0)  update_edge(geometries[i], _this.curvature);   // only needed if spline edge
      geometries[i].verticesNeedUpdate = true;
    }

    // Show labels if set
    // It creates the labels when this options is set during visualization
    if(_this.show_labels)
    {
      var length = graph.nodes.length;
      for(var i=0; i<length; i++)
      {
        var node = graph.nodes[i];
        var text_scale = 500 * Math.max(0.75, node.scale);
        if(node.data.label_object != undefined) {
          node.data.label_object.position.x = node.data.draw_object.position.x;
          node.data.label_object.position.y = node.data.draw_object.position.y - 100;
          node.data.label_object.position.z = node.data.draw_object.position.z - 5*Math.sign(node.data.draw_object.position.z);
          node.data.label_object.lookAt(camera.position);
        } else {
          if(node.data.title != undefined) {
            var label_object = new THREE.Label(node.data.title, _this.fg, text_scale, node.data.draw_object);
          }
          node.data.label_object = label_object;
          scene.add( node.data.label_object );
        }
      }
    } else {
      var length = graph.nodes.length;
      for(var i=0; i<length; i++) {
        var node = graph.nodes[i];
        if(node.data.label_object != undefined) {
          scene.remove( node.data.label_object );
          node.data.label_object = undefined;
        }
      }
    }

    // render scenes
    _this.renderer.render( scene, camera );
    object_selection.render(scene2, camera);
    _this.renderer.render( scene2, camera );
  }

  /**
   *  Prints info from the attribute info_text.
   */
  function printInfo(text) {
    var str = '';
    for(var index in info_text) {
      if(str != '' && info_text[index] != '') {
        str += " - ";
      }
      str += info_text[index];
    }
    _this.infobox.innerHTML = str;
    _this.infobox.style.color = _this.fgcss;
    _this.infobox.style.top = "" + 10 - _this.renderer.domElement.height + "px";
  }
};
