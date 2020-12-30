include <laserlib.scad>;


thickness = 6; // thikness

$fa= $preview ? 12 : 1;
$fs= $preview ? 1 : 0.1;



$flatPack = true;  // Toggle for whether or not to flatpack you build
$spaceing = 2;     // When flatpacking 
$kerf=0.2;


llFlatPack(x=0, sizes = [40,40]){
    color("green")
    llPos([0,20+thickness,thickness], [90,0,0], thickness)
        llClip(startPos=[5,0])
        llClip(startPos=[65,0], mirror = true)
        llCutoutSquare([70,40]);

    llPos([0,0,0], [0,0,0], thickness)
        llClipHole(startPos=[5,20])
        llClipHole(startPos=[65,20], mirror = true)
        llCutoutSquare([70,40]);
}