/*
 * Adapted from simple_graph.js by David Piegza
 *
 * Implements a simple graph drawing with force-directed placement in 3D.
 *
 * Parameters:
 * options = {
 *
 *   nodes: A data frame with at least the 5 columns id, label, size,
 *          color, type. The id column is the data frame row number.
 *
 *   edges: A data frame with at least the 4 columns from, to, size, color.
 *          The from and to columns indicate node ids.
 * }
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
    obj.widget.renderer.setSize(width, height);
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
 */
var Widget = Widget || {};
Widget.SimpleGraph = function()
{
//  var options = options || {};
  this.layout_options = {};
  this.show_title = true;
  this.show_labels = false;

  var camera, controls, scene, interaction, geometry, object_selection, sprite_map, img_map;
  var stats;
  var info_text = {};
  var graph = new Graph();
  var geometries = [];
  var _this = this;

  _this.init = function (el, width, height)
  {
    _this.renderer = new THREE.WebGLRenderer({alpha: true, antialias: true, precision: "lowp"});
    _this.renderer.sortObjects = false;  // see https://github.com/mrdoob/three.js/issues/3490
    _this.renderer.setSize(el.innerWidth, el.innerHeight);
    _this.el = el;

    camera = new THREE.PerspectiveCamera(40, width/height, 1, 1000000);
    camera.position.z = 5000;

    controls = new THREE.TrackballControls(camera);
    controls.rotateSpeed = 0.5;
    controls.zoomSpeed = 5.2;
    controls.panSpeed = 1;
    controls.noZoom = false;
    controls.noPan = false;
    controls.staticMoving = false;
    controls.dynamicDampingFactor = 0.3;
    controls.keys = [ 65, 83, 68 ]; // a s d also r for 'reset'
    controls.addEventListener('change', render);

    scene = new THREE.Scene();

    // Node geometry (used by spherical nodes)
    geometry = new THREE.SphereGeometry( 64, 25, 25 );
    // Node sprite (used by circular nodes)
    var t = 256;
    var size = t * t;
    var dataColor = new Uint8Array( size * 4 );
    for(var i = 0; i < size * 4; i++) dataColor[i] = 0;
    for(var i = 0; i < t; i++)
    {
      for(var j = 0; j < t; j++)
      {
        var x = 2*i/(t-1) - 1;
        var y = 2*j/(t-1) - 1;
        var z = x*x + y*y;
        var k = i*t + j;
        if(z <= 0.75)
        {
          dataColor[k*4] = 255;
          dataColor[k*4 + 1] = 255;
          dataColor[k*4 + 2] = 255;
          dataColor[k*4 + 3] = 255;
        } else if(z > 0.75 && z <= 1)
        {
          dataColor[k*4] = 0;
          dataColor[k*4 + 1] = 0;
          dataColor[k*4 + 2] = 0;
          dataColor[k*4 + 3] = 255;
        }
      }
    }
    sprite_map = new THREE.DataTexture(dataColor, t, t, THREE.RGBAFormat, THREE.UnsignedByteType );
    sprite_map.needsUpdate = true;
    t = 128;
    var dataColor2 = new Uint8Array( t * t * 4 );
    for(var i = 0; i < t * t * 4; i++) dataColor2[i] = 255;
    for(var i = 0; i < t; i++)
    {
      for(var j = 0; j < t; j++)
      {
        var k = i*t + j;
        if((i/4) == Math.floor(i/4) || (j/4) == Math.floor(j/4))
        {
          dataColor2[k*4] = 190;
          dataColor2[k*4 + 1] = 190;
          dataColor2[k*4 + 2] = 190;
          dataColor2[k*4 + 3] = 255;
        }
      }
    }
    img_map = new THREE.DataTexture(dataColor2, t, t, THREE.RGBAFormat, THREE.UnsignedByteType );
    img_map.needsUpdate = true;

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
      info.style.left = "40%";
      info.style.zIndex = 100;
      info.style.fontFamily = "Sans";
      info.style.fontSize = "x-large";
      info.style.position = "absolute";
      info.style.top = "10px";
      el.appendChild(info);
    }
  }


  /* create_graph
   * x.nodes a data frame with at least columns id, label, size, color
   * x.edges a data frame with at least columns from, to, size, color
   * x.title  a character plot title
   */
  _this.create_graph = function(x)
  {
    _this.node_type = x.nodeType;
    if(x.bg) _this.renderer.setClearColor(new THREE.Color(x.bg));
    _this.fg = new THREE.Color(x.fg);
    _this.fgcss = x.fg;

    if(x.img && x.img.dataURI)
    { 
      img = document.createElement("img");
      img.src = x.img.img;
      img_map = new THREE.Texture();
      img_map.minFilter = THREE.LinearFilter;
      img_map.image = img;
      img_map.needsUpdate = true;
    } else if(x.img)
    { 
      img_map = THREE.ImageUtils.loadTexture(x.img.img);
      img_map.minFilter = THREE.LinearFilter;
    }

    for(var j=0; j < x.nodes.length; j++)
    {
      var node = new Node(x.nodes[j].id);
      node.data.title = x.nodes[j].label;
      node.color = new THREE.Color(x.nodes[j].color);
      node.scale = x.nodes[j].size/2;
      graph.addNode(node);
      drawNode(node);
    }
    for(var j=0; j < x.edges.length; j++)
    {
      var source = graph.getNode(x.edges[j].from);
      var target = graph.getNode(x.edges[j].to);
      graph.addEdge(source, target);
      drawEdge(source, target, new THREE.Color(x.edges[j].color), x.edges[j].size);
    }

    _this.show_labels = x.showLabels;
    _this.layout_options.width = _this.layout_options.width || 2000;
    _this.layout_options.height = _this.layout_options.height || 2000;
    _this.layout_options.iterations = _this.layout_options.iterations || 2000;
    _this.layout_options.attraction = x.attraction;
    _this.layout_options.repulsion = x.repulsion;
    _this.layout_options.iterations = x.iterations;
    graph.layout = new Layout.ForceDirected(graph, _this.layout_options);
    graph.layout.init();
    controls.owner = graph;
    info_text.title = x.main;
  }


  /**
   *  Create a node object and add it to the scene.
   */
  function drawNode(node)
  {
    var draw_object;
    var draw_scale = 1;
    var smaterial = new THREE.SpriteMaterial({color: node.color, map: sprite_map, opacity: 1});
    if(_this.node_type == 1)
    {
      draw_object = new THREE.Mesh(geometry, new THREE.MeshBasicMaterial({color: node.color, opacity: 0.9, map: img_map}));
    } else
    {
      draw_object = new THREE.Sprite(smaterial);
      draw_scale = 100;
    }
    draw_object.scale.x = draw_object.scale.y = draw_scale * node.scale;
    var area = 50;
    draw_object.position.x = Math.floor(Math.random() * (area + area + 1) - area);
    draw_object.position.y = Math.floor(Math.random() * (area + area + 1) - area);
    draw_object.position.z = Math.floor(Math.random() * (area + area + 1) - area);
    draw_object.nodeid = node.id;
    node.data.draw_object = draw_object;
    node.position = draw_object.position;
    scene.add( node.data.draw_object );
  }

  /**
   *  Create an edge object (line) and add it to the scene.
   */
  function drawEdge(source, target, color, size) {
    material = new THREE.LineBasicMaterial({ color: color, opacity: 1, linewidth: size });

    var tmp_geo = new THREE.Geometry();
    tmp_geo.vertices.push(source.data.draw_object.position);
    tmp_geo.vertices.push(target.data.draw_object.position);

//    line = new THREE.Line( tmp_geo, material, THREE.LinePieces );
    var line = new THREE.Line( tmp_geo, material );
    line.scale.x = line.scale.y = line.scale.z = 1;
    line.originalScale = 1;

    geometries.push(tmp_geo);
    scene.add( line );
  }

  _this.animate = function ()
  {
    requestAnimationFrame(_this.animate);
    controls.update();
    render();
    if(_this.show_title) {
      printInfo();
    }
  };

  function render() {
    // Generate layout if not finished
    if(!graph.layout.finished) {
      info_text.calc = "<span style='color: red'>Calculating layout...</span>";
      graph.layout.generate();
    } else {
      info_text.calc = "";
    }

    // Update position of lines (edges)
    for(var i=0; i< geometries.length; i++) {
      geometries[i].verticesNeedUpdate = true;
    }

    // Show labels if set
    // It creates the labels when this options is set during visualization
    if(_this.show_labels) {
      var length = graph.nodes.length;
      for(var i=0; i<length; i++) {
        var node = graph.nodes[i];
        if(node.data.label_object != undefined) {
          node.data.label_object.position.x = node.data.draw_object.position.x;
          node.data.label_object.position.y = node.data.draw_object.position.y - 100;
          node.data.label_object.position.z = node.data.draw_object.position.z - 5*Math.sign(node.data.draw_object.position.z);
          node.data.label_object.lookAt(camera.position);
        } else {
          if(node.data.title != undefined) {
            var label_object = new THREE.Label(node.data.title, _this.fg, 600 * node.scale, node.data.draw_object);
          } else {
            var label_object = new THREE.Label(node.id, _this.fg, 600 * node.scale, node.data.draw_object);
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

// XXX make options
    var ambientLight = new THREE.AmbientLight(0xffffff);
    scene.add( ambientLight );

    object_selection.render(scene, camera);

    // render scene
    _this.renderer.render( scene, camera );
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
    document.getElementById("graph-info").innerHTML = str;
    document.getElementById("graph-info").style.color = _this.fgcss;
  }

  // Generate random number
  function randomFromTo(from, to) {
    return Math.floor(Math.random() * (to - from + 1) + from);
  }

  // Stop layout calculation
  this.stop_calculating = function()
  {
    graph.layout.stop_calculating();
  }
};
