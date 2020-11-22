include <laserlib.scad>;

th = 6; // thikness

$flatPack = false;  // Toggle for whether or not to flatpack you build
$spaceing = 2;     // When flatpacking 

myWidth = 100;
myDepth = 123;
myHeight = 145;
shelfHeight = 40;

llFlatPack(x = 0 , sizes=[myDepth,myHeight,myDepth,myDepth+50,myHeight-shelfHeight]){
    // bottom
    llPos([0,0,0],0,th)
    llFingers(startPos=[0,0,0], angle=0, length=myWidth,edge="r",startCon=[0,0])
    llFingers(startPos=[0,0,0], angle=90, length=myDepth,edge="l", startCon=[2,2])
    llCutoutSquare(size=[myWidth,myDepth]);

    // front
    llPos([0,th,0],[90,0,0],th)
        llFingers(startPos = [0,0,0], endPos=[myWidth,0,0],edge="r", startCon=[1,1])
            llFingers(startPos=[0,0,0], angle=90,length=myHeight,edge="l", startCon=[1,1])
                llFingers(startPos = [0,shelfHeight,0], angle = 0, length = myWidth, startCon=[1,1])
                    llCutoutSquare(size=[myWidth,myHeight]){
                        translate([myWidth/2,myHeight-50])myBlob();
                    }
    

    // side1
    llPos([th,0,0],[0,-90,0],th){
        llFingers(startPos=[0,0,0], angle=0, length = myHeight, edge="r", startCon=[0,0])
            llFingers(startPos = [shelfHeight,0,0], angle = 90, length = myDepth, startCon=[1,1])
                llFingers(startPos=[0,0,0], angle=90, length = myDepth, edge = "l", startCon=[3,3])
                    llCutoutSquare(size=[myHeight,myDepth]);

    } 
    
    //shelf
    #llPos([0,0,shelfHeight],[0,0,0],th){
        llFingers(startPos=[0,0], endPos=[myWidth,0],startCon=[0,0],edge="r")
            llFingers(startPos=[0,0], endPos=[0,myDepth,0],startCon=[0,0], edge="l")
                llClipHole(startPos=[myWidth-10,myDepth/2], mirror = true)    
                    llCutoutSquare(size=[myWidth,myDepth]);
    }

    // clipin
    color("red")
    llPos([th,myDepth/2+th,shelfHeight+th],[90,0,0],th){
        llClip(startPos=[myWidth-th-10,0,0], angle=0, mirror = true)    
            llCutoutSquare(size=[myWidth-th,myHeight-shelfHeight-th]);
    }
}

llFlatPack(x = myWidth+2, sizes=[myDepth,myDepth]){
    llPos([myWidth+5,0,0],[0,0,0],th)
        llFingers(startPos=[0,0,0], angle=0, length=myWidth,startCon=[2,0], edge="r")
        llFingers(startPos=[0,myDepth-th,0], angle=0, length=myWidth,startCon=[3,1], edge="l")
        llCutoutSquare([myWidth,myDepth]);
}

llIgnore(){
    *translate([30,30,shelfHeight+th])cylinder(r=10,h=20);
}

module myBlob(){
    for(i=[0:6]){
        rotate(360/6*i)cube([40,5,th]);
    }
}

