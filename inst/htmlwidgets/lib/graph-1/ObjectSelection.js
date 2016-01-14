/**
  @author David Piegza

  Implements a selection for objects in a scene.

  It invokes a callback function when the mouse enters and when it leaves the object.
  Based on a Three.js selection example.

  Parameters:
    domElement: HTMLDomElement
    selected: callback function, passes the current selected object (on mouseover)
    clicked: callback function, passes the current clicked object
 */

THREE.ObjectSelection = function(parameters)
{
  var parameters = parameters || {};

  this.domElement = parameters.domElement || document;
  this.controls = parameters.controls || {};
  this.graph = parameters.graph || {};
//  this.projector = new THREE.Projector();
  this.INTERSECTED;

  var _this = this;

  var callbackSelected = parameters.selected;
  var callbackClicked = parameters.clicked;
  var mouse = { x: 0, y: 0 };
  var down = false;
  var cam;

  this.domElement.addEventListener( 'mousedown', onDocumentMouseDown, false );
  function onDocumentMouseDown(event)
  {
    down = true;
    if(_this.INTERSECTED)
    {
      _this.controls.enabled = false;
    }
  }
  this.domElement.addEventListener( 'mouseup', onDocumentMouseUp, false );
  function onDocumentMouseUp(event)
  {
    down = false;
    _this.controls.enabled = true;
  }

// The next two functions walk the graph to assemble connections and distances
// from the starting node. They are not efficient (especially setdiff)!!
// Improve me!!
  function setdiff(A, B)
  {
    return A.filter(function(x) { return B.indexOf(x) < 0 });
  }

  function tribe(node, family, distance)
  {
    var ext = setdiff(node.nodesFrom.concat(node.nodesTo), family);
    for(var j=0; j < ext.length; j++) ext[j].distance = distance;
    family = family.concat(ext);
    for(var j=0; j < ext.length; j++)
    {
      family = family.concat(setdiff(tribe(ext[j], family, distance + 1), family));
    }
    return family;
  }

  this.domElement.addEventListener( 'mousemove', onDocumentMouseMove, false );
  function onDocumentMouseMove(ev)
  {
    var canvasRect = this.getBoundingClientRect();
    var dx, dy;
    mouse.x = 2 * (ev.clientX - canvasRect.left) / canvasRect.width - 1;
    mouse.y = -2 * (ev.clientY - canvasRect.top) / canvasRect.height + 1;

    if(down && _this.INTERSECTED)
    {
      var vector = new THREE.Vector3();
      vector.set(mouse.x, mouse.y, 0.5);
      vector.unproject(cam);
      var dir = vector.sub(cam.position).normalize();
      var distance = - cam.position.z / dir.z;
      var pos = cam.position.clone().add(dir.multiplyScalar(distance));
      var N = _this.graph.getNode(_this.INTERSECTED.nodeid);
      if(typeof(N) == "undefined") return;
      dx = N.position.x - pos.x;
      dy = N.position.y - pos.y;
      N.position.x = pos.x;
      N.position.y = pos.y;
      var others = tribe(N, [N], 1);
      for(var j=1; j < others.length; j++)  // start at 1 cause others[0] = N.
      {
        var d = Math.pow(0.70, 1.5*others[j].distance);
        others[j].position.x = others[j].position.x - dx * d;
        others[j].position.y = others[j].position.y - dy * d;
      }
    }
  }

  this.domElement.addEventListener( 'click', onDocumentMouseClick, false );
  function onDocumentMouseClick( event ){
    if(_this.INTERSECTED) {
      if(typeof callbackClicked === 'function') {
        callbackClicked(_this.INTERSECTED);
      }
    }
  }

  this.render = function(scene, camera) {
    var vector = new THREE.Vector3( mouse.x, mouse.y, 0.5 );
    vector.unproject( camera );
    var raycaster = new THREE.Raycaster(camera.position, vector.sub(camera.position).normalize());
    var intersects = raycaster.intersectObject(scene, true);
cam = camera;
if(!down)
{
    if( intersects.length > 0 ) {
      if ( this.INTERSECTED != intersects[ 0 ].object ) {
        if ( this.INTERSECTED ) {
          this.INTERSECTED.material.color.setHex( this.INTERSECTED.currentHex );
        }
        this.INTERSECTED = intersects[ 0 ].object;
        this.INTERSECTED.currentHex = this.INTERSECTED.material.color.getHex();
        if(this.INTERSECTED.material.color.getHexString().startsWith("ff"))
        {
          this.INTERSECTED.material.color.setHex( 0x00ffff );
        } else {
          this.INTERSECTED.material.color.setHex( 0xff0000 );
        }
        if(typeof callbackSelected === 'function') {
          callbackSelected(this.INTERSECTED);
        }
      }
    } else {
      if ( this.INTERSECTED ) {
        this.INTERSECTED.material.color.setHex( this.INTERSECTED.currentHex );
      }
      this.INTERSECTED = null;
      if(typeof callbackSelected === 'function') {
        callbackSelected(this.INTERSECTED);
      }
    }
}
  }
}
