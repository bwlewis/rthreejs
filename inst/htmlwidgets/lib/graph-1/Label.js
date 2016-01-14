THREE.Label = function(text, color, scale, parameters)
{
  var parameters = parameters || {};
  var color = color || 0x000000;
  var scale = scale || 1;
  var canvas = document.createElement( "canvas" );

  function create()
  {
    var width, height;
    height = 64;
    width = 512;
    canvas.width = width;
    canvas.height = height;
    var context = canvas.getContext('2d');
    context.fillStyle = "#" + color.getHexString();
    context.textAlign = "center";
    context.textBaseline = "top";
    context.font = "48px Arial";
    context.fillText(text, width / 2, 0);
    var amap = new THREE.Texture(canvas);
    amap.generateMipmaps = false;
    amap.minFilter = THREE.LinearFilter;
    amap.magFilter = THREE.LinearFilter;
    amap.needsUpdate = true;
    var mat = new THREE.SpriteMaterial({
      map: amap,
      transparent: true,
      useScreenCoordinates: false,
      color: 0xffffff });
    sp = new THREE.Sprite(mat);
    sp.scale.set(scale, scale/8, scale);
    return sp;
  }
  return create();
}
