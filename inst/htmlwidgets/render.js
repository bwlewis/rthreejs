HTMLWidgets.widget(
{
  name: "render",
  type: "output",

  initialize: function(el, width, height)
  {
    var w = parseInt(width);
    var h = parseInt(height);
    var g = new Widget.render(w, h);
    if(w == 0) w = 1; // set minimum object size
    if(h == 0) h = 1;
    return {widget: g, width: parseInt(width), height: parseInt(height)};
  },

  resize: function(el, width, height, obj)
  {
    obj.width = width;
    obj.height = height;
    obj.widget.camera.aspect = width / height;
    obj.widget.camera.updateProjectionMatrix();
    obj.widget.renderer.setSize(obj.width, obj.height);
    obj.widget.animate();
  },

  renderValue: function(el, x, obj)
  {
    obj.widget.init(el, obj.widget.init_width, obj.widget.init_height); // init here, see issue #52
    obj.widget.create_plot(x); // see below
    obj.widget.renderer.setSize(obj.width, obj.height);
    obj.widget.animate();
  }
})


var Widget = Widget || {};
Widget.render = function(w, h)
{

  var _this = this;
  var clock = new THREE.Clock();
  var mixer;
  var is_animated = false;

  _this.init = function (el, width, height)
  {
    if(Detector.webgl)
    {
      _this.renderer = new THREE.WebGLRenderer({alpha: true, antialias: true});
      _this.renderer.GL = true;
    } else {
      _this.renderer = new THREE.CanvasRenderer();
      _this.renderer.GL = false;
    }
    _this.renderer.sortObjects = false;
    _this.renderer.autoClearColor = false;
    _this.renderer.setSize(width, height);
    _this.el = el; // stash a reference to our container for posterity
    _this.width = width;
    _this.height = height;
    _this.scene = new THREE.Scene();

    if(height > 0) _this.camera = new THREE.PerspectiveCamera(40, width / height, 1e-5, 10000);
    else _this.camera = new THREE.PerspectiveCamera(40, 1, 1e-5, 10000);

    _this.controls = new THREE.StateOrbitControls(_this.camera, _this.el);
    _this.controls.rotateSpeed = 0.6;
    _this.controls.zoomSpeed = 1.5;
    _this.controls.panSpeed = 1;
    _this.controls.enableZoom = true;
    _this.controls.enablePan = true;
    _this.controls.enableDamping = true;
    _this.controls.dampingFactor = 0.15;
    _this.controls.addEventListener('change', render);


    while (el.hasChildNodes()) {
      el.removeChild(el.lastChild);
    }
    el.appendChild(_this.renderer.domElement);
  }

/*
 * Simplified low-level rendering API
 * Required fields:
 * x.datauri  dataURI encoded scene or group compatible with ObjectLoader
 * x.scene    logical, if true then datauri represents a threejs scene
 * x.bg         background color
 * x.camera_position  3-element perspective camera position vector
 * x.camera_lookat    3-element perspective camera look at vector
 * Optional fields:
 * x.pointlight a vector of pointLight objects, each with 'color' (charachter) and 'position' (3-element numeric) fields
 * x.ambient scene ambient light color
 * x.fov  perspective camera field of view (numeric)
 */
  _this.create_plot = function(x)
  {
    new THREE.ObjectLoader().load(x.datauri, function (loadedScene)
    {
// XXX what about geometries? (https://threejs.org/docs/index.html#api/loaders/ObjectLoader)
      if(loadedScene.type && loadedScene.type == "scene") _this.scene = loadedScene;
      else _this.scene.add(loadedScene);
      _this.scene.background = new THREE.Color(x.bg);
      _this.camera.position.set(x.camera_position[0], x.camera_position[1], x.camera_position[2]);
      _this.camera.lookAt(new THREE.Vector3(x.camera_lookat[0], x.camera_lookat[1], x.camera_lookat[2]));
      if(x.fov) _this.camera.fov = x.fov;
      if(x.lights)
      {
        for(i=0; i < x.lights.length; i++)
        {
          var p = new THREE.PointLight(new THREE.Color(x.lights[i].color), 1);
          p.position.x = x.lights[i].position[0];
          p.position.y = x.lights[i].position[1];
          p.position.z = x.lights[i].position[2];
          _this.scene.add(p);
        }
      }
      if(x.ambeint) _this.scene.add(new THREE.AmbientLight(new THREE.Color(x.ambient)));
      if(loadedScene.animations)
      {
        is_animated = true;
        mixer = new THREE.AnimationMixer(loadedScene);
        mixer.clipAction(loadedScene.animations[0]).play();
      }
      animate();
    }, null, function (err) { console.log(err); });
  }

  _this.animate = function ()
  {
    animate();
  }

  animate = function ()
  {
    requestAnimationFrame(animate); // (hogs CPU)
    render();
  };

  function render()
  {
    if(is_animated) mixer.update(clock.getDelta());
    _this.renderer.clear();
    _this.renderer.render(_this.scene, _this.camera);
  }

};
