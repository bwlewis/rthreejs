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
    d3.select(el).node().appendChild(r.domElement);
    return r;
  },

  resize: function(el, width, height, renderer)
  {
    renderer.setSize( width, height );
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
  renderValue: function(el, x, renderer)
  {
    var img, scene,  geometry, tex, earth;
    var down = false;
    var sx = 0, sy = 0;

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

    scene = new THREE.Scene();
    geometry = new THREE.SphereGeometry(200,50,50);
    x = JSON.parse(x);
    if(x.dataURI)
    {
      img = document.createElement("img");
      img.src = x.img;
      tex = new THREE.Texture();
      tex.image = img;
      tex.needsUpdate = true;
    } else
    {
      tex = THREE.ImageUtils.loadTexture( x.img );
    }

    var material = new THREE.MeshLambertMaterial({map: tex, color: 0x0000ff, emissive:0x0000ff});

    earth = new THREE.Mesh( geometry, material );
    earth.position.x = earth.position.y = 0;
    scene.add( earth );

    camera = new THREE.PerspectiveCamera( 35, renderer.domElement.width / renderer.domElement.height, 1, 10000 );
    camera.position.x = 800*Math.sin(earth.rotation.x) * Math.cos(earth.rotation.y);
    camera.position.y = 800*Math.sin(earth.rotation.y);
    camera.position.z = 800*Math.cos(earth.rotation.x) * Math.cos(earth.rotation.y);
    camera.lookAt(scene.position);

    var customMaterial = new THREE.ShaderMaterial( 
    {
      uniforms: 
      { 
        "c":   { type: "f", value: 1.3 },
        "p":   { type: "f", value: 9.0 },
        glowColor: { type: "c", value: new THREE.Color(0xeeeeff) },
        viewVector: { type: "v3", value: camera.position }
      },
      vertexShader:   vertexShader,
      fragmentShader: fragmentShader,
      side: THREE.FrontSide,
      blending: THREE.AdditiveBlending,
      transparent: true
    }   );
    var atmo = new THREE.Mesh( geometry.clone(), customMaterial.clone() );
    atmo.position = earth.position;
    atmo.scale.multiplyScalar(1.03);
    if(GL) scene.add(atmo);

    scene.add( new THREE.AmbientLight( 0xddddff ) );
    scene.add( new THREE.AmbientLight( 0x9999ff ) );

// Add the data points
    var phi, theta, lat, lng, colr, size;
    var group = new THREE.Geometry();
    var bg = new THREE.BoxGeometry(1,1,1);
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
        size = parseInt(x.value[i]);
      else
        size = parseInt(x.value);
      phi = (90 - lat) * Math.PI / 180;
      theta = - lng * Math.PI / 180;
      var point = new THREE.Mesh(bg, bm);
      point.position.x = 200 * Math.sin(phi) * Math.cos(theta);
      point.position.y = 200 * Math.cos(phi);
      point.position.z = 200 * Math.sin(phi) * Math.sin(theta);
      point.scale.x = point.scale.y = 1; point.scale.z = size;
      point.lookAt(earth.position);
//      point.updateMatrix();
      var j;
      for (j = 0; j<point.geometry.faces.length; j++) {
        point.geometry.faces[j].color = new THREE.Color(colr);
      }
      THREE.GeometryUtils.merge(group,point);
    }
    var points = new THREE.Mesh(group, bm);
    scene.add(points);

    window.onmousedown = function (ev)
    {
      down = true; sx = ev.clientX; sy = ev.clientY;
    };

    function mousewheel(event)
    {
      var fovMAX = 160;
      var fovMIN = 1;
      camera.fov -= event.wheelDeltaY * 0.02;
      camera.fov = Math.max( Math.min( camera.fov, fovMAX ), fovMIN );
      camera.projectionMatrix = new THREE.Matrix4().makePerspective(camera.fov,  renderer.domElement.width/renderer.domElement.height, camera.near, camera.far);
    }
    window.onmousewheel = function(ev) {ev.preventDefault();};
    window.addEventListener('DOMMouseScroll', mousewheel, true);
    window.addEventListener('mousewheel', mousewheel, true);

    window.onmouseup = function(){ down = false; };
    window.onmousemove = function(ev)
    {
      ev.preventDefault();
      if (down) {
        var dx = ev.clientX - sx;
        var dy = ev.clientY - sy;
        earth.rotation.y += dx*0.01;
        earth.rotation.x += 0.01*dy;
        points.rotation.y += dx*0.01;
        points.rotation.x += 0.01*dy;
        sx += dx;
        sy += dy;
      }
    };

    animate();

    function animate() {
      renderer.clear();
      requestAnimationFrame( animate );
      render();
    }

    function render() {
      camera.lookAt(scene.position);
      renderer.render( scene, camera );
    }

  }

})
