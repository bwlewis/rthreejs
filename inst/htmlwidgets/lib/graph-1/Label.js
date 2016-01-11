THREE.Label = function(text, color, scale, parameters)
{
  var parameters = parameters || {};
  var color = color || 0x000000;
  var scale = scale || 1;
  var canvas = document.createElement( "canvas" );

  function create()
  {
    var size = 256;
    canvas.width = size;
    canvas.height = size;
    var context = canvas.getContext('2d');
    context.fillStyle = "#" + color.getHexString();
    context.textAlign = 'center';
    context.font = '24px Arial';
    context.fillText(text, size / 2, size / 2);
    var amap = new THREE.Texture(canvas);
    amap.needsUpdate = true;
    var mat = new THREE.SpriteMaterial({
      map: amap,
      transparent: true,
      useScreenCoordinates: false,
      color: 0xffffff });
    sp = new THREE.Sprite(mat);
    sp.scale.set(scale, scale, scale);
    return sp;
  }
  return create();
}
