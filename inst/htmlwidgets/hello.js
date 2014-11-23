HTMLWidgets.widget(
{

  name: "hello",
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
    r.setClearColor("white");
    d3.select(el).node().appendChild(r.domElement);
    return r;
  },

  resize: function(el, width, height, renderer)
  {
  },

  renderValue: function(el, x, renderer)
  {
    var scene = new THREE.Scene();
    var camera = new THREE.PerspectiveCamera(45, renderer.domElement.width/renderer.domElement.height, 0.1, 10000);
    var geometry = new THREE.BoxGeometry( 1, 1, 1 );
    var material = new THREE.MeshBasicMaterial( { color: 0x0000ff } );
    var cube = new THREE.Mesh( geometry, material );
    scene.add( cube );

    camera.position.z = 5;
    function render() {
      requestAnimationFrame( render );
      cube.rotation.x += 0.1;
      cube.rotation.y += 0.1;
      renderer.render( scene, camera );
    }
    render();
  }
})
