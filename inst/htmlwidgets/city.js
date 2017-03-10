var heightmap = [];
var colormap = [];
var animatemap = [];
var widthmap = [];
var categorymap = [];
var categorynamemap = [];
var addressmap = [];
var inlinkmap = [];
var traficmap = [];
var rescodemap = [];
var levelmap = [];
var majesticmap = [];
var targetmap = [];
var googlebotmap = [];

var watermap = [];
var spritey;

var objects = [];
var curbs = [];
var bedrocks = [];

var radius = 100;
var radiusMax = radius * 10;
var baseColor = 0x333333;
var foundColor = 0x12C0E3;

var intersectColor = 0x00D66B;
var intersected;
var oldColor;

var DEBUG = false;
		
function createInfoCanvas(message) {
  document.getElementById("info").innerHTML = message;
}

function buildAxis( src, dst, colorHex, dashed ) {
      
  var geom = new THREE.Geometry(),
  mat;

  if(dashed) {
    mat = new THREE.LineDashedMaterial({ linewidth: 3, color: colorHex, dashSize: 3, gapSize: 3 });
  } else {
    mat = new THREE.LineBasicMaterial({ linewidth: 3, color: colorHex });
  }

  geom.vertices.push( src.clone() );
  geom.vertices.push( dst.clone() );
  geom.computeLineDistances(); // This one is SUPER important, otherwise dashed lines will appear as simple plain lines

  var axis = new THREE.Line( geom, mat, THREE.LinePieces );

  return axis;

}	



HTMLWidgets.widget(
{
  
  name: "city",
  type: "output",
  

  initialize: function(el, width, height)
  {
    var r;
    
    if(Detector.webgl)
    {
      r = new THREE.WebGLRenderer({ antialias:true });
      r.shadowMapEnabled = false;
      GL=true;
    } else
    {
      r = new THREE.CanvasRenderer();
      GL=false;
    }
    
    //setup Renderer
    r.setPixelRatio( 1 );
    r.setSize(parseInt(width), parseInt(height));
    r.setClearColor("black");
    el.appendChild(r.domElement);
    
    var ratio = width  / height;
    var c = new THREE.PerspectiveCamera(75, ratio, 1, radius * 100);
    c.position.set(500, 500, 500);
	  c.lookAt(new THREE.Vector3(0, 0, 0));
	  c.position.z = radius * 10;
	  
	  //init Control
	  ctrl = new THREE.OrbitControls( c, r.domElement );
	  ctrl.maxPolarAngle = Math.PI/2;	  
	  
    //init Scene, Raycaster, Vector for mouse
    var s = new THREE.Scene();
    var ray = new THREE.Raycaster();
    var m = new THREE.Vector3();
    
    // lights
	  var l = new THREE.HemisphereLight(colors.WHITE, colors.WHITE, 0.5);
	  l.castShadow = false;

	  var bl = new THREE.DirectionalLight(colors.WHITE, 0.1);
	  bl.position.set(-100, 400, 50);
	  bl.castShadow = false;    
	  
	  s.add(bl,l);	
	  
    var axes = new THREE.Object3D();

    axes.add( buildAxis( new THREE.Vector3( 0, 0, 0 ), new THREE.Vector3( 0, 10000, 0 ), 0x00FF00, false ) ); // Y

	  s.add(axes);	  
    
    // create stuff
    return {renderer:r, raycaster: ray, camera:c, mouse:m, scene: s, buildings:[], control: ctrl, width: parseInt(width), height: parseInt(height)};
  },

  resize: function(el, width, height, stuff)
  {
        
    stuff.width = width;
    stuff.height = height;    
    
    stuff.renderer.setSize( width, height );
	  stuff.camera.aspect = width / height;
	  
	  stuff.camera.updateProjectionMatrix();

    stuff.renderer.render( stuff.scene, stuff.camera );
    
  },
  

// We expect x to contain the following fields:
// x.posx :
// x.posy : 
// x.height :
// x.width :
// x.recode :
// x.poscategory : 
// x.posaddress :
// x.posinlink :
// x.postrafic;
// x.poslevel : 
// x.posmajestic :
// x.postarget : 
// x.posgooglebot :
// stuff is a tuple with a renderer, camera, and scene. Through the JavaScript
// weirdness of call-by-sharing, we can modify that state.
  renderValue: function(el, x, stuff)
  {
    var img, geometry, tex;
    var down = false;
    var sx = 0, sy = 0;
    
    //create park 
    function setupPark(x, z, w, l, max){
    	var trees =  [];
    	
    	if (max>city.tree_max) max=city.tree_max;
    	
    	for(var i=0; i<max; i++){
    		var tree_x = getRandInt(x-w/2, x+w/2);
    		var tree_z = getRandInt(z-l/2, z+l/2);
    		trees.push(new Tree(tree_x, tree_z).group);
    	}
    	//merge trees for this block into single mesh
    	if(trees.length) stuff.scene.add(mergeMeshes(trees));    	
    	
    }    
    
    //recursively create buildings return array of meshes
    function setupBuildings(r, i, j, x, z, w, l, h, sub, color, buildings, cb){
      var offset, half, between;
    
      //array of buildings for this block
      buildings = buildings || [];
      
      //add rim building
      //var r = getRandInt(0,20);
    
      building = new Building({
    		h : h,
    		w: w, 
    		l: l,
    		x: x,
    		z: z,
    		rim : r,
    		color: color
      });
      buildings.push(building.group);
    	
      var b = mergeMeshes(buildings);
      b.userData = { ipos:i, 
                     jpos:j 
                   };
                   
      stuff.scene.add(b);
      
      objects.push(b);
    
    }    
    
    //init scene
    //remove old objects
    objects = [];
    curbs = [];
    
    while (stuff.scene.children.length > 3) {
            stuff.scene.remove(stuff.scene.children[stuff.scene.children.length - 1]);
    }
    
    
    // check for manual override of the detector
    var heightmap = [],
    colormap = [],
    widthmap = [],
    categorymap = [],
    categorynamemap = [],
    addressmap = [],
    inlinksmap = [],
    traficmap = [],
    rescodemap = [],
    levelmap = [],
    majesticmap = [],
    targetmap = [],
    googlebotmap = [],
    cols=0;
    
    //init
    city.blocks_x = x.blocks_x;
    city.blocks_z = x.blocks_z;
    city.width = city.block * x.blocks_x;
    city.length = city.block * x.blocks_z;

    city.heightmax = x.height_max;
    city.weightmax = x.weight_max;
    
    if (x.block>0)
      cols = x.block;
      
    if (x.posaddress!=null)
    {
      //init the grid matrix
      for ( var i = 0; i < cols; i++ ) {
        heightmap[i] = []; 
        colormap[i] = []; 
        widthmap[i] = []; 
        categorymap[i] = [];
        categorynamemap[i] = [];
        addressmap[i] = [];
        inlinkmap[i] = [];
        rescodemap[i] = [];      
        traficmap[i] = [];
        rescodemap[i] = [];
        levelmap[i] = [];
        majesticmap[i] = [];
        targetmap[i] = [];
        googlebotmap[i] = [];
      }
      
      if(x.posx != null)
      {
  
        for (var i = 0; i < x.posx.length; i++)
        {
          posx = parseInt(x.posx[i]);
          posy = parseInt(x.posy[i]);
          height = parseInt(x.posheight[i]);
          width = parseInt(x.poswidth[i]);
          rescode = parseInt(x.posrescode[i]);
          category = x.poscategory[i];
          categoryname = x.poscategoryname[i];
          address = x.posaddress[i];
          inlink = x.posinlink[i];
          trafic = x.postrafic[i];
          level = x.poslevel[i];
          majestic = x.posmajestic[i];
          target = x.postarget[i];
          googlebot = x.posgooglebot[i];
  
          heightmap[posx-1][posy-1]   = height;
          colormap[posx-1][posy-1]    = rescode;
          widthmap[posx-1][posy-1]    = width;
          categorymap[posx-1][posy-1] = category;
          categorynamemap[posx-1][posy-1] = categoryname;
          addressmap[posx-1][posy-1]  = address;
          inlinkmap[posx-1][posy-1]  = inlink;        
          traficmap[posx-1][posy-1]  = trafic;
          //rescodemap[posx-1][posy-1]  = rescode;
          levelmap[posx-1][posy-1]  = level;
          majesticmap[posx-1][posy-1]  = majestic;
          targetmap[posx-1][posy-1]  = target;
          googlebotmap[posx-1][posy-1]  = googlebot;
          
        }
        
      }
      
      //console.log(levelmap);
      
      //// ADD GROUND
  	  var street_h = city.curb_h*2;
  
  	  //lowest ground Layer
  	  bedrock = getBoxMesh(colors.LIGHT_BROWN, city.width, city.base, city.length);
  	  bedrock.position.y = (-(city.base/2) - city.water_height - street_h); 
  	  bedrock.receiveShadow = false;
  	  
  	  stuff.scene.add(bedrock);
  	  
  	  /////////////////////////////////////
  
  
  	  for (var i = 0; i < city.blocks_x; i++) {		
  		  for (var j = 0; j < city.blocks_z; j++) {	
  
  				var x = ((city.block*i) + city.block/2) - city.width/2;
  				var z = ((city.block*j) + city.block/2) - city.length/2;
  				
  				//get values from heightmap array
  				var hm = heightmap[i][j];
  				
  				//get building height for block 
  				var max = 200;
  				var min = 10;
  				var h = Math.round((hm*max)/city.heightmax)+min;
  				
          /////////////////////////////
  		
  				//max possible distance from center of block
  				var w = city.block-city.road_w;
  				//with inner block margins
  				var inner = w-(city.inner_block_margin*2);
  				var min = 20;
  				var wh;
  				

  				if (city.weightmax<=0)
  				  wh = (widthmap[i][j]*inner)/5;
  				else
  				  wh= Math.round((googlebotmap[i][j]*40)/city.weightmax)+min;
  				
  				////////////////////////////////////////////////
  				
  				var r = majesticmap[i][j];
  				
  				//create curb mesh
  				//TODO : add special color if page objective
  				if (targetmap[i][j]!=10)
  				  var curb_color = colors.GROUND;
  				else
  				  var curb_color = colors.BLACK;
  				
  				curb = getBoxMesh(curb_color, w, city.curb_h, w);
  				curb.position.set(x, city.curb_h/2, z);

  	      curb.userData = { ipos:i, 
                 jpos:j 
               };
  				
  				stuff.scene.add(curb);	
  				
  				curbs.push(curb);
  				
  				//get values from colormap array
  				var cm = colormap[i][j];
  				  
          var building_color;
  				
  				//rescode 200
  				if (cm==2) {
  				  if (categorymap[i][j]!=null) {
  				    var color = eval(categorymap[i][j]);
  				    var building_color = getRGBscaleColor(color);
  				  }
  				  else {
  				    var color = 0x996633;
  				    var building_color = getRGBscaleColor(color);
  				  }
  				}
          else {
           	// server error
    			  if(cm==5)
    			    color = 0xCC0000;
    			  // bad request
    			  else if (cm==4)
    			    color = 0x0000FF;
    			  // redirect
    			  else if (cm==3)
    			    color = 0x0066FF;
    				    
    			  var building_color = getRGBscaleColor(color);
          }
  					
  				if (levelmap[i][j]<2) {
  				  
  				  console.log("levelmap",levelmap[i][j]);
  				  console.log("addressmap",addressmap[i][j]);
  				  
  				}
  				  
  	
  	      //si trafic
  				if (hm>0) {
  				  setupBuildings(r, i, j, x, z, wh, wh,  h, city.subdiv, building_color); 
  				  //setupBuildings(r, i, j, x, z, wh, inner,  h, city.subdiv, building_color); 
  				}
  				//si pas de trafic mais googlebot actif
  				else if (googlebotmap[i][j]>0) {
  				  setupPark(x, z, wh, wh, googlebotmap[i][j]);
  				}
  				
  				
  		  }
  	  }
    }    	

  
    // Set initial rotation
    el.onmousedown = function (ev)
    {
      down = true; sx = ev.clientX; sy = ev.clientY;
    };
    
    el.onmouseup = function(){ down = false; };

    function mousewheel(event)
    {
      var fovMAX = 50;
      var fovMIN = 10;
      event.wheelDeltaY = event.wheelDeltaY || -10*event.detail || event.wheelDelta;
      
      
      if(GL) stuff.camera.fov -= event.wheelDeltaY * 0.02;
      else stuff.camera.fov -= event.wheelDeltaY * 0.0075;
      
      stuff.camera.fov = Math.max( Math.min( stuff.camera.fov, fovMAX ), fovMIN );
      
      stuff.camera.projectionMatrix = new THREE.Matrix4().makePerspective(stuff.camera.fov,  stuff.width/stuff.height, stuff.camera.near, stuff.camera.far);
      
      render();
      
    }
    el.onmousewheel = function(ev) {ev.preventDefault();};
    el.addEventListener("DOMMouseScroll", mousewheel, true);
    el.addEventListener("mousewheel", mousewheel, true);
    //el.addEventListener( "mousedown", mousedown, false );

    el.onmousedown = function(event)
    {
      
      event.preventDefault();

      // The following will translate the mouse coordinates into a number
      // ranging from -1 to 1, where
      //      x == -1 && y == -1 means top-left, and
      //      x ==  1 && y ==  1 means bottom right
        
			var rect_canvas = stuff.renderer.domElement.getBoundingClientRect();

			stuff.mouse.x = ( (event.clientX-rect_canvas.left) / stuff.renderer.domElement.width ) * 2 - 1;
			stuff.mouse.y = - ( (event.clientY-rect_canvas.top) / stuff.renderer.domElement.height ) * 2 + 1;   
			stuff.mouse.z = 0.5;

			//http://stackoverflow.com/questions/11036106/three-js-projector-and-ray-objects
			stuff.raycaster.setFromCamera( stuff.mouse, stuff.camera);

			var intersections = stuff.raycaster.intersectObjects( objects );
			var numObjects = objects.length;
			var txt = "";

			if ( intersections.length > 0 ) {
        if ( intersected != intersections[ 0 ].object ) {
          
  			  var ipos = intersections[0].object.userData.ipos;
  			  var jpos = intersections[0].object.userData.jpos;
  			  
  			  txt += "" + addressmap[ipos][jpos] +
  			  "<br/>Level:" + levelmap[ipos][jpos] +
  			  " Trafic:" + traficmap[ipos][jpos] +
          " Inlinks:" + inlinkmap[ipos][jpos] +
          " Rescode:" + colormap[ipos][jpos] + "XX" +          
          " Category:" + categorynamemap[ipos][jpos];
          
          
            if ( googlebotmap[ipos][jpos]!= undefined)
              txt += " GoogleBot:" + googlebotmap[ipos][jpos]
          
          if (addressmap[ipos][jpos]!=undefined) {
  			    createInfoCanvas(txt);
          }
          
        }
			} 
      else {
			  
			  var intersections = stuff.raycaster.intersectObjects( curbs );
			  var numObjects = curbs.length;
			  var txt = "";
			  
			  if ( intersections.length > 0 ) {
          if ( intersected != intersections[ 0 ].object ) {
          
  			    var ipos = intersections[0].object.userData.ipos;
  			    var jpos = intersections[0].object.userData.jpos;
  			  
  			    txt += "" + addressmap[ipos][jpos] +
  			    "<br/>Level:" + levelmap[ipos][jpos] +
  			    " Trafic:" + traficmap[ipos][jpos] +
            " Inlinks:" + inlinkmap[ipos][jpos] +
            " Rescode:" + colormap[ipos][jpos] + "XX" +         
            " Category:" + categorynamemap[ipos][jpos];
            
            if ( googlebotmap[ipos][jpos]!= undefined)
              txt += " GoogleBot:" + googlebotmap[ipos][jpos]
          
            if (addressmap[ipos][jpos]!=undefined) {
  			      createInfoCanvas(txt);
            }

          }
			  }
			  
			}				

      
		}    

    el.onmousemove = function(ev)
    {
      ev.preventDefault();
      var dx = ev.clientX - sx;
      var dy = ev.clientY - sy;
      sx += dx;
      sy += dy;
        
      render();
    };
    
//  We disabled the usual Three.js animation technique in favor of simply
//  rendering after mouse updates. This results in a bit of choppiness for
//  Canvas renderings, but is compatible with more browsers and with older
//  versions of RStudio because it doesn't need requestAnimationFrame.

//    animate();
//    function animate() {
//      renderer.clear();
//      requestAnimationFrame( animate );
//      render();
//    }

    function render() {
      stuff.renderer.clear();
      stuff.camera.lookAt(stuff.scene.position);
      //stuff.camera.lookAt(new THREE.Vector3(0, 0, 0));
      stuff.renderer.render( stuff.scene, stuff.camera );
      
      
    }
    render();
  }
})
