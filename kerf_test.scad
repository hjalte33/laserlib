include <laserlib.scad>;


thickness = 6; // thikness

$fa= $preview ? 12 : 1;
$fs= $preview ? 1 : 0.1;



$flatPack = true;  // Toggle for whether or not to flatpack you build
$spaceing = 2;     // When flatpacking 
kerf_1 = 0.2;
kerf_2 = 0.3;

width = 100;
depth = 40;


llFlatPack(x=0, sizes = [depth,depth]){
    llPos([0,0,0], [0,0,0], thickness)
        llFingers(startPos=[0,0],angle=0, nFingers=5, length=width, startCon=[0,1], edge="r", $kerf=kerf_1)
        llFingers(startPos=[0,depth/2-thickness/2],angle=0, nFingers=5, length=width, startCon=[0,1], $kerf=kerf_1)
        llFingers(startPos=[width,depth],angle=180, nFingers=5, length=width, startCon=[0,1], edge="r", $kerf=kerf_2)
        llCutoutSquare([width,depth]){
            translate([width-2,2])linear_extrude(thickness)text(str(kerf_1),size=3, halign="right" );
            translate([width-2,depth/2-thickness/2])linear_extrude(thickness)text(str(kerf_1),size=3, halign="right" );
            translate([width-2,depth-thickness*2])linear_extrude(thickness)text(str(kerf_2),size=3, halign="right" );
        };

    llPos([0,32,0], [0,0,0], thickness)
        llFingers(startPos=[0,0],angle=0, nFingers=5, length=width, startCon=[0,1], edge="r", $kerf=kerf_1)
        llFingers(startPos=[0,depth/2-thickness/2],angle=0, nFingers=5, length=width, startCon=[0,1], $kerf=kerf_2)
        llFingers(startPos=[width,depth],angle=180, nFingers=5, length=width, startCon=[0,1], edge="r", $kerf=kerf_2)
        llCutoutSquare([width,depth]){

            translate([width-2,2])linear_extrude(thickness)text(str(kerf_1),size=3, halign="right" );
            translate([width-2,depth/2-thickness/2])linear_extrude(thickness)text(str(kerf_2),size=3, halign="right" );
            translate([width-2,depth-thickness*2])linear_extrude(thickness)text(str(kerf_2),size=3, halign="right" );
        };
}