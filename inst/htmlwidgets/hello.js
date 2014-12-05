HTMLWidgets.widget(
{

  name: "hello",
  type: "output",

  initialize: function(el, width, height)
  {
    var r;
    FIRST = true;
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

  renderValue: function(el, x, renderer)
  {
    var img, scene, camera, geometry, tex, object, directionalLight, particleLight, pointLight;
    x = JSON.parse(x);

    if(FIRST)
    {
    if(x.dataURI)
    { 
      img = document.createElement("img");
      img.src = x.img;
      tex = new THREE.Texture();
      tex.image = img;
    } else
    {
      tex = THREE.ImageUtils.loadTexture( x.img );
    }

      scene = new THREE.Scene();
      camera = new THREE.PerspectiveCamera( 40, renderer.domElement.width / renderer.domElement.height, 1, 2000 );
      camera.position.set( 0, 200, 0 );
      camera.lookAt(scene.position);

      geometry = new THREE.SphereGeometry(50,32,32);

      tex.needsUpdate = true;
      material = new THREE.MeshPhongMaterial( { map: tex, bumpMap: tex, bumpScale: 1, color: "black", ambient: x.ambient, specular: x.specular, shininess: x.shininess, metal: true, shading:  THREE.SmoothShading } );

      object = new THREE.Mesh( geometry, material );
      object.position.x = 0;
      object.position.y = 0;
      scene.add( object );

      scene.add( new THREE.AmbientLight( 0xaaaaaa ) );
      directionalLight = new THREE.DirectionalLight( 0xffffff, 1 );
      directionalLight.position.set( 1, 1, 1 ).normalize();
      scene.add( directionalLight );
      particleLight = new THREE.Mesh( new THREE.SphereGeometry( 4, 8, 8 ), new THREE.MeshBasicMaterial( { color: 0xffffff } ) );
      scene.add( particleLight );
      pointLight = new THREE.PointLight( 0xffffff, 2, 800 );
      particleLight.add( pointLight );
      FIRST = false;
      animate();
    } else
    {
      material.shininess = x.shininess;
      material.ambient = new THREE.Color(x.ambient);
      material.specular = new THREE.Color(x.specular);
    }

    function animate() {
      requestAnimationFrame( animate );
      render();
    }
    function render() {
      var timer = Date.now() * 0.00025;
      object.rotation.y += 0.01;
      object.rotation.x += 0.01;
      particleLight.position.x = Math.sin( timer * 7 ) * 300;
      particleLight.position.y = Math.cos( timer * 5 ) * 400;
      particleLight.position.z = Math.cos( timer * 3 ) * 300;
      renderer.render( scene, camera );
    }
  }


})
