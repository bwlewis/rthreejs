//=========================================
// HELPER FUNCTIONS
//=========================================
//get a numerical value to represent a string
function encode(string) {
    var number = "0x";
    var length = string.length;
    for (var i = 0; i < length; i++)
        number += string.charCodeAt(i).toString(16);
    return number;
}
//get a string value to represent a number
function decode(number) {
    var string = "";
    number = number.slice(2);
    var length = number.length;
    for (var i = 0; i < length;) {
        var code = number.slice(i, i += 2);
        string += String.fromCharCode(parseInt(code, 16));
    }
    return string;
}
//get query string values
function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}
//map val (0-1) to a range with optional weight
function mapToRange(val, min, max, exp){
	exp = exp || 1;
	var weighted = Math.pow(val, exp);
	//make the highest little higher
	if (val >= 0.90) weighted = val;
	var num = Math.floor(weighted * (max - min)) + min;
	return num;
}
//get a random in in range
function getRandInt(min, max, exp) {
	return mapToRange(Math.random(), min, max, exp);
}
//map value from 0-1 to a luminosity
function getGreyscaleColor(val) {
	return new THREE.Color().setHSL(0, 0, val);
}
//map value from 0-1 to a luminosity
function getRGBscaleColor(hex) {
	return new THREE.Color(hex);
}
//get values from noise map
function getNoiseValue(x, z, freq) {
	freq = freq || city.noise_frequency;
	var value = Math.abs(noise.perlin2(x/freq, z/freq));
	return value;
}
//is a point outside the city bounds
function outsideCity(x, z) {
	return (Math.abs(x) > city.width/2) ||
		(Math.abs(z) > city.length/2);
}
//get x,z from index
function getCoordinateFromIndex(index, offset) {
	return (-(offset/2) + (index * city.block)) + (city.block/2);
}
//get rows or columns with no buildings
function getEmptyRows() {
	var i, low, lri, lci, empty = [];
	//loop through rows
	for(i=0; i<heightmap.length;i++){
		var row = heightmap[i];
		// low = (low < _.sum(row)) ? low : _.sum(row);
		//all values in row are under tree threshold
		row = _.reject(row, function(n) { return n < city.tree_threshold; });
		if(!row.length){
			empty.push({axis: 0, index: i});
		}
	}
	//loop through columns
	for(i=0; i<heightmap[0].length;i++){
		var col = _.map(heightmap, function(row){ return row[i]; });
		col = _.reject(col, function(n) { return n < city.tree_threshold; });
		if(!col.length){
			empty.push({axis: 1, index: i});
		}
	}
	return empty;
}
//normalize array values to 0-1
function normalizeArray(arr) {
	var min = Math.min.apply(null, arr);
   var max = Math.max.apply(null, arr);
	return arr.map(function(num) {
		return ((num-min)/(max-min));
	});
}
//carete a box mesh with a geometry and material
function getBoxMesh(color, w, h, l, x, y, z, shadow) {
	shadow = (typeof shadow === "undefined") ? false : shadow;
	material = new THREE.MeshLambertMaterial({ color: color});	
	geom = new THREE.BoxGeometry(w, h, l);
	mesh = new THREE.Mesh(geom, material);
	mesh.position.set(x || 0, y || 0, z || 0);
	/*mesh.receiveShadow = true;
	if(shadow){
		mesh.castShadow = true;
	}*/
	return mesh;
}
//carete a box mesh with a geometry and material
function getBoxMeshOpts(options) {
	var o=options||{};
	return getBoxMesh(o.color, o.w, o.h, o.l, o.x, o.y, o.z, o.shadow);
}
//water mesh
function getWaterMesh(w, h, l, x, y, z) {
	material = new THREE.MeshPhongMaterial({color:colors.WATER, transparent: true, opacity: 0.6 } );
	geom = new THREE.BoxGeometry(w, h, l);
	mesh = new THREE.Mesh(geom, material);
	mesh.position.set(x || 0, y || 0, z || 0);
	mesh.receiveShadow = false;
	mesh.castShadow = false;
	return mesh; 
}
//carete a cylinder mesh with a geometry and material
function getCylinderMesh(color, rb, h, rt, x, y, z) {
	var material = new THREE.MeshLambertMaterial({ color: color});	
	var geom = new THREE.CylinderGeometry( rt, rb, h, 4, 1 );
	var mesh = new THREE.Mesh(geom, material);
	mesh.rotation.y = Math.PI/4;
	mesh.position.set(x || 0, y || 0, z || 0);
	mesh.receiveShadow = true;
	mesh.castShadow = true;
	return mesh;
}
//carete a cylinder mesh with a geometry and material
function getCylinderMeshOpts(options) {
	var o = options || {};
	return getCylinderMesh(o.color, o.rb, o.h, o.rt, o.x, o.y, o.z);
}
//returns true percent of the time
function chance(percent){
	return (Math.random() < percent/100.0);
}
//return 1 or -1
function randDir(){
	return Math.round(Math.random()) * 2 - 1;
}
//pythagorean theorem, return c
function pathag(a, b){
	return Math.sqrt(Math.pow(a, 2)+Math.pow(b, 2));
}
//merge geometries of meshes
function mergeMeshes (meshes, shadows, material) {
	shadow = (typeof shadow === "undefined") ? false : shadow;
	material = material || meshes[0].material;
	var combined = new THREE.Geometry();
	for (var i = 0; i < meshes.length; i++) {
		meshes[i].updateMatrix();
		combined.merge(meshes[i].geometry, meshes[i].matrix);
	}
	var mesh = new THREE.Mesh(combined, material);
	//FIX : block shadow
	/*
	if(shadows){
		mesh.castShadow = true;
		mesh.receiveShadow = true;
	}
	*/
	return mesh;
}