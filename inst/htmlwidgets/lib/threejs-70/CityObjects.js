
var colors = {
	BUILDING: 0xE8E8E8,
	GROUND: 0x81A377,
	TREE: 0x216E41,
	WHITE: 0xffffff,
	BLACK: 0x000000,
	DARK_BROWN: 0x545247,
	LIGHT_BROWN: 0x736B5C,
	GREY: 0x999999,
	WATER: 0x4B95DE,
	TRAIN: 0x444444,
	CARS:[
		0xCC4E4E
	]
};


var nb_urls = 10000;

//basic city options
city = {
	//height of bedrock layer
	base: 40,
	//depth of the water and earth layers
	water_height: 20,
	//block size (w&l)
	block: 80, 
	//num blocks x //default : 10
	blocks_x: 40,
	//num blocks z
	blocks_z: 40,
	//road width
	road_w: 16,
	//heightmax
	heightmax: 10,
	//heightmax
	weightmax: 0,	
	//curb height
	curb_h: 2,
	//block slices // default : 2
	subdiv: 1, 
	//sidewalk width
	inner_block_margin: 5,
	//max building height
	build_max_h: 400,
	//min building height
	build_min_h: 50,
	//deviation for height within block
	block_h_dev: 10,
	//exponent of height increase 
	build_exp: 6,
	//chance of blocks being water
	water_threshold: 0.1, 
	//chance of block containg trees
	tree_threshold: 0.1,
	//max trees per block
	tree_max: 20,
	//max bridges
	bridge_max: 1,
	//beight heaight
	bridge_h: 25,
	//max cars at one time
	car_max: 10,
	//train max
	train_max: 1,
	//maximum car speed
	car_speed_min: 2,
	//minimum car speed
	car_speed_max: 3,
	//train speed
	train_speed: 4,
	//noise factor, increase for smoother noise
	noise_frequency: 8,
	//seed for generating noise
	//seed: Math.random()
	seed: Math.random()
};

//city.width = city.block * city.blocks_x;
//city.length = city.block * city.blocks_z;
//store default options
//_city = _.clone(city);

//console.log(city.width);
//console.log(city.length);


////////////////////////

//=========================================
// OBJECTS
//=========================================
var Building = function(opts) {
	this.parts = [];
	
	//50% chance of building having a rim.

	var inset = getRandInt(2,4);
	var rim = opts.rim;
	
	var rim_opts = {
		//color: opts.color,
		color: colors.BLACK,
		h: rim,
		y: opts.h + (rim/2) + city.curb_h,
		shadow: false
	};
	
	//building core
	this.parts.push(getBoxMeshOpts({
		color: opts.color,
		w: opts.w,
		h: opts.h,
		l: opts.l,
		x: opts.x,
		y: (opts.h/2)+city.curb_h,
		z: opts.z,
		shadow: false
	}));
	
	//console.log("x",opts.x,"y",(opts.h/2)+city.curb_h,"z",opts.z);
	
	//draw rim on top of some buildings
	/*
	if(chance(50)){
		this.parts.push(getBoxMeshOpts(_.assign(rim_opts, {
			w: opts.w,
			l: inset,
			x: opts.x,
			z: opts.z - (opts.l/2 - inset/2)
		})));
		this.parts.push(getBoxMeshOpts(_.assign(rim_opts, {
			w: opts.w,
			l: inset,
			x: opts.x,
			z: opts.z + (opts.l/2 - inset/2)
		})));
		this.parts.push(getBoxMeshOpts(_.assign(rim_opts, {
			w: inset,
			l: opts.l-(inset*2),
			x: opts.x - (opts.w/2 - inset/2),
			z: opts.z
		})));
		this.parts.push(getBoxMeshOpts(_.assign(rim_opts, {
			w: inset,
			l: opts.l-(inset*2),
			x: opts.x + (opts.w/2 - inset/2),
			z: opts.z
		})));		
	}
	//additional details
	if(chance(50)){
		this.parts.push(getBoxMeshOpts(_.assign(rim_opts, {
			w: getRandInt(opts.w/4, opts.w/2),
			l: getRandInt(opts.l/4, opts.l/2),
			x: opts.x - (5*randDir()),
			z: opts.z - (5*randDir())
		})));
	}
	
	
	//antenna only on tall buildings
	if(chance(25) && opts.tall){
	*/
	
	//Add antenna accordind Majestic
	//console.log(rim);
	
	if(rim>1) {
	  
		this.parts.push(getBoxMeshOpts(_.assign(rim_opts, {
			w: 5,
			l: 5,
			color: colors.BLACK,
			//x: opts.x - (5*randDir()),
			x: opts.x,
			z: opts.z,
			//z: opts.z - (5*randDir()),
			h: city.build_max_h*rim
		})));
		
		/*
		this.parts.push(getBoxMeshOpts(_.assign(rim_opts, {
			w: getRandInt(opts.w/4, opts.w/2),
			l: getRandInt(opts.l/4, opts.l/2),
			x: opts.x - (5*randDir()),
			z: opts.z - (5*randDir())
		})));
		*/
		
	}
	
	if(rim>0) { 	
	  rim_opts.color=colors.WHITE; 
		var top = getBoxMeshOpts(_.assign(rim_opts, {
			w: opts.w - (opts.w/3),
			l: opts.w - (opts.w/3),
			x: opts.x,
			z: opts.z,
			//h: getRandInt(15, 30)
			color: colors.WHITE,
			h:50
		}));
		top.castShadow = false;
		this.parts.push(top);
	}

	//merged mesh
	var merged = mergeMeshes(this.parts);
	this.group = merged;
};

var Tree = function(x, z){
	this.parts = [];
	var h = getRandInt(2, 4);
	trunk = getBoxMesh(colors.LIGHT_BROWN, 2, h, 2, x, h/2+city.curb_h, z);
	leaves = getCylinderMesh(colors.TREE, 5, 10, 0,  x, h+5+city.curb_h, z);
	leaves2 = getCylinderMesh(colors.TREE, 5, 10, 0,  x, leaves.position.y+5, z);
	leaves.rotation.y = Math.random();
	this.parts.push(leaves, leaves2, trunk);
	this.group = mergeMeshes(this.parts);
};

/*
var Intersection = function(x, z){
	this.axis = Math.round(Math.random());
	this.change = function(){
		this.axis = this.axis ? 0 : 1;
	};
};
*/

////////////////////////////
