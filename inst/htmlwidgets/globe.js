HTMLWidgets.widget(
{

  name: "globe",
  type: "output",

  initialize: function(el, width, height)
  {
    var r;
    if(Detector.webgl)
    {
      r = new THREE.WebGLRenderer({antialias: true});
      GL=true;
    } else
    {
      r = new THREE.CanvasRenderer();
      GL=false;
    }
    r.setSize(parseInt(width), parseInt(height));
    r.setClearColor("black");
    el.appendChild(r.domElement);
    var c = new THREE.PerspectiveCamera( 35, r.domElement.width / r.domElement.height, 1, 10000 );
    var s = new THREE.Scene();
    return {renderer:r, camera:c, scene: s, width: parseInt(width), height: parseInt(height)};
  },

  resize: function(el, width, height, stuff)
  {
    stuff.camera.aspect = width / height;
    stuff.camera.updateProjectionMatrix();
    stuff.renderer.setSize( width, height );
    stuff.renderer.render( stuff.scene, stuff.camera );
  },

// We expect x to contain the following fields:
// x.img: Either a string path to a texture image (server mode), or
//        a list that contains a base64-encoded image. We detect the
//        latter case by looking for a variable named dataURI.
// x.dataURI Optional. If present indicates x.img is a dataURI.
// x.lat: Latitude data points (north degrees, use negative for south)
// x.long: Longitude data points (west degrees, use negative for east)
// x.color: Either a single color value, or a vector of color values
//          of length x.data.length for each point.
// x.value: Either a single height value, or a vector of values
//          of length x.data.length for each point.
// x.lightcolor: A color value for the ambient light in the scene
// x.arcs: four-column data frame with columns fromlat fromlong tolat tolong
// x.arcsColor: Either a single color value, or a vector of color values
//              of length matching the numer of rows of x.arcs.data.
// x.arcsLwd: Either a single line width value, or a vector of values
//              of length matching the numer of rows of x.arcs.data.
// x.arcsHeight: Height for all arcs above earth between 0 and 1.
// stuff is a tuple with a renderer, camera, and scene. Through the JavaScript
// weirdness of call-by-sharing, we can modify that state.
  renderValue: function(el, x, stuff)
  {
    var img, geometry, tex, earth;
    var down = false;
    var sx = 0, sy = 0;
//    tex = THREE.ImageUtils.loadTexture(x.img, {}, function() {render();});
    tex = new THREE.TextureLoader().load(x.img, function(texture) {render();});

    var vertexShader = [
    'uniform vec3 viewVector;',
    'uniform float c;',
    'uniform float p;',
    'varying float intensity;',
    'void main(){',
    'vec3 vNormal = normalize( normalMatrix * normal );',
    'vec3 vNormel = normalize( normalMatrix * viewVector );', 
    'intensity = pow( c - dot(vNormal, vNormel), p );',
    'gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );}'].join('\n');

    var fragmentShader = [
    'uniform vec3 glowColor;',
    'varying float intensity;',
    'void main(){',
    'vec3 glow = glowColor * intensity;',
    'gl_FragColor = vec4( glow, 1.0 );}'].join('\n');

// check for manual override of the detector
    if(!(x.renderer==null))
    { 
      if(x.renderer=="canvas" && GL==true)
      {
        stuff.renderer = new THREE.CanvasRenderer();
        GL=false;
        stuff.renderer.setSize(stuff.width, stuff.height);
        stuff.renderer.setClearColor("black");
        el.removeChild(el.children[0]);
        el.appendChild(stuff.renderer.domElement);
      }
    }

    if(!x.lightcolor) x.lightcolor = 0xaaeeff;
    if(!x.emissive) x.emissive = 0x000000;
    if(!x.bodycolor) x.bodycolor = 0xffffff;
    if(!x.diameter) x.diameter = 200;
    if(!x.segments) x.segments = 50;
    if(!x.pointsize) x.pointsize = 1;
    else x.pointsize = parseFloat(x.pointsize);
    if(!x.fov) x.fov = 35;
    if(!x.rotationlat) x.rotationlat = 0.0;
    if(!x.rotationlong) x.rotationlong = 0.0;

    if(x.bg) stuff.renderer.setClearColor(x.bg);

    stuff.scene = new THREE.Scene();
    geometry = new THREE.SphereGeometry(x.diameter, x.segments, x.segments);


    var material = new THREE.MeshLambertMaterial({map: tex, color: x.bodycolor, emissive: x.emissive});

    earth = new THREE.Mesh( geometry, material );
    earth.position.x = earth.position.y = 0;
    stuff.scene.add(earth);

    stuff.camera = new THREE.PerspectiveCamera( x.fov, stuff.renderer.domElement.width / stuff.renderer.domElement.height, 1, 10000 );
    stuff.camera.position.x = 800*Math.sin(earth.rotation.x) * Math.cos(earth.rotation.y);
    stuff.camera.position.y = 800*Math.sin(earth.rotation.y);
    stuff.camera.position.z = 800*Math.cos(earth.rotation.x) * Math.cos(earth.rotation.y);
    stuff.camera.lookAt(stuff.scene.position);

    var customMaterial = new THREE.ShaderMaterial( 
    {
      uniforms: 
      { 
        "c":   { type: "f", value: 1.3 },
        "p":   { type: "f", value: 9.0 },
        glowColor: { type: "c", value: new THREE.Color(0xeeeeff) },
        viewVector: { type: "v3", value: stuff.camera.position }
      },
      vertexShader:   vertexShader,
      fragmentShader: fragmentShader,
      side: THREE.FrontSide,
      blending: THREE.AdditiveBlending,
      transparent: true
    }   );
    var atmo = new THREE.Mesh( geometry.clone(), customMaterial.clone() );
    atmo.position = earth.position;
    atmo.scale.multiplyScalar(1.01);
    if(GL && x.atmosphere) stuff.scene.add(atmo);

    stuff.scene.add( new THREE.AmbientLight( x.lightcolor ) );
    stuff.scene.add( new THREE.AmbientLight( x.lightcolor ) );

// Add the data points
    var group = new THREE.Geometry();
    if(x.lat != null)
    {
      if(!Array.isArray(x.lat)) x.lat = [x.lat];
      if(!Array.isArray(x.long)) x.long = [x.long];
      var phi, theta, lat, lng, colr, size;
      var bg = new THREE.BoxGeometry(1, 1, 1);
      var bm = new THREE.MeshBasicMaterial({color: 0xffffff, vertexColors: THREE.FaceColors});
      var point;

      for (var i = 0; i < x.lat.length; ++i)
      {
        lat = parseFloat(x.lat[i]);
        lng = parseFloat(x.long[i]);
        if(Array.isArray(x.color))
          colr = new THREE.Color(x.color[i]);
        else
          colr = new THREE.Color(x.color);
        if(Array.isArray(x.value))
          size = parseFloat(x.value[i]);
        else
          size = parseFloat(x.value);
        phi = (90 - lat) * Math.PI / 180;
        theta = - lng * Math.PI / 180;
        var point = new THREE.Mesh(bg, bm);
        point.position.x = x.diameter * Math.sin(phi) * Math.cos(theta);
        point.position.y = x.diameter * Math.cos(phi);
        point.position.z = x.diameter * Math.sin(phi) * Math.sin(theta);
        point.scale.x = point.scale.y = x.pointsize;
        point.scale.z = size;
        point.lookAt(earth.position);
        var j;
        for (j = 0; j < point.geometry.faces.length; j++) {
          point.geometry.faces[j].color = new THREE.Color(colr);
        }
        point.updateMatrix();
        group.merge(point.geometry, point.matrix);
      }
    }
    var points = new THREE.Mesh(group, bm);
    stuff.scene.add(points);


// Add the arcs
    var arcs = new THREE.Object3D();
    if(x.arcs != null)
    {
      var phi1, phi2, theta1, theta2, colr, size;
      for (var i = 0; i < x.arcs.fromlat.length; ++i)
      {
        if(Array.isArray(x.arcsColor))
          colr = new THREE.Color(x.arcsColor[i]);
        else
          colr = new THREE.Color(x.arcsColor);
        if(Array.isArray(x.arcsLwd))
          size = parseFloat(x.arcsLwd[i]);
        else
          size = parseFloat(x.arcsLwd);
        phi1 = (90 - x.arcs.fromlat[i]) * Math.PI / 180;
        theta1 = - x.arcs.fromlong[i] * Math.PI / 180;
        phi2 = (90 - x.arcs.tolat[i]) * Math.PI / 180;
        theta2 = - x.arcs.tolong[i] * Math.PI / 180;

        var start = new THREE.Vector3(
                      x.diameter * Math.sin(phi1) * Math.cos(theta1),
                      x.diameter * Math.cos(phi1),
                      x.diameter * Math.sin(phi1) * Math.sin(theta1));
        var end   = new THREE.Vector3(
                      x.diameter * Math.sin(phi2) * Math.cos(theta2),
                      x.diameter * Math.cos(phi2),
                      x.diameter * Math.sin(phi2) * Math.sin(theta2));
        var dist = start.clone().sub(end).length();
        var mid = start.clone().lerp(end,0.5);
        var midLength = mid.length()
        mid.normalize();
        mid.multiplyScalar( midLength + dist * x.arcsHeight );
        var normal = (new THREE.Vector3()).subVectors(start,end);
        normal.normalize();

        var distanceHalf = dist * 0.5;
        var startAnchor = start;
        var midStartAnchor = mid.clone().add( normal.clone().multiplyScalar( distanceHalf ) );
        var midEndAnchor = mid.clone().add( normal.clone().multiplyScalar( -distanceHalf ) );
        var endAnchor = end;
        var splineCurveA = new THREE.CubicBezierCurve3( start, startAnchor, midStartAnchor, mid);
        var splineCurveB = new THREE.CubicBezierCurve3( mid, midEndAnchor, endAnchor, end);
        var path = new THREE.CurvePath();
        path.add(splineCurveA);
        path.add(splineCurveB);
        var curveMaterial = new THREE.LineBasicMaterial({
              color: colr,
              transparent: true,
              opacity: x.arcsOpacity,
              linewidth: size
         });
//         var curve = new THREE.Line(path.createPointsGeometry(20), curveMaterial);
         var pathgeo = new THREE.Geometry();
         pathgeo.setFromPoints(path.getPoints(20));
         var curve = new THREE.Line(pathgeo, curveMaterial);
         arcs.add(curve);
      }
    }
    stuff.scene.add(arcs);



// Set initial rotation
    earth.rotation.x = x.rotationlat;
    earth.rotation.y = x.rotationlong;
    points.rotation.x = x.rotationlat;
    points.rotation.y = x.rotationlong;
    arcs.rotation.x = x.rotationlat;
    arcs.rotation.y = x.rotationlong;

    el.onmousedown = function (ev)
    {
      down = true; sx = ev.clientX; sy = ev.clientY;
    };
    el.onmouseup = function(){ down = false; };

    function mousewheel(event)
    {
      var fovMAX = 120;
      var fovMIN = 10;
      event.wheelDeltaY = event.wheelDeltaY || -10*event.detail || event.wheelDelta;
      if(GL) stuff.camera.fov -= event.wheelDeltaY * 0.02;
      else stuff.camera.fov -= event.wheelDeltaY * 0.0075;
      stuff.camera.fov = Math.max( Math.min( stuff.camera.fov, fovMAX ), fovMIN );
      var ymax = stuff.camera.near * Math.tan((Math.PI / 180) * stuff.camera.fov * 0.5);
      var ymin = - ymax;
      var xmin = ymin * stuff.camera.aspect;
      var xmax = ymax * stuff.camera.aspect;
      stuff.camera.projectionMatrix = new THREE.Matrix4().makePerspective(xmin, xmax, ymax, ymin, stuff.camera.near, stuff.camera.far);
      render();
    }
    el.onmousewheel = function(ev) {ev.preventDefault();};
    el.addEventListener("DOMMouseScroll", mousewheel, true);
    el.addEventListener("mousewheel", mousewheel, true);

    el.onmousemove = function(ev)
    {
      ev.preventDefault();
      if (down) {
        var dx = ev.clientX - sx;
        var dy = ev.clientY - sy;
        earth.rotation.y += dx*0.01;
        earth.rotation.x += 0.01*dy;
        points.rotation.y = earth.rotation.y;
        points.rotation.x = earth.rotation.x;
        arcs.rotation.y = earth.rotation.y;
        arcs.rotation.x = earth.rotation.x;
        sx += dx;
        sy += dy;
        render();
      }
    };

    function render() {
      stuff.renderer.clear();
      stuff.camera.lookAt(stuff.scene.position);
      stuff.renderer.render(stuff.scene, stuff.camera);
    }
    render();
  }
})
