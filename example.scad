include <laserlib.scad>;

th = 6; // thikness

$flatPack = false;  // Toggle for whether or not to flatpack you build
$spaceing = 2;     // When flatpacking 

myWidth = 100;
myDepth = 123;
myHeight = 145;


llFlatPack(x = 0 , sizes=[myDepth,myHeight,myDepth]){
    // bottom
    llCutoutSquare(th = th, size=[myWidth,myDepth], pos=[0,0,0]){
        llFingers(startPos=[0,0,0], angle=0, length=myWidth,edge=true,startCon=[2,0], inverse = false);
        llFingers(startPos=[0,0,0], angle=90, length=myDepth,edge=true, startCon=[2,2], inverse = false);
    }

    // front
    *llCutoutSquare(th = th, size=[myWidth,myHeight],pos=[0,th,0],ang=[90,0,0]){
        #llFingers(startPos = [0,0,0], endPos=[myWidth,0,0],edge=true, startCon=[2,0],inverse = true);
        llFingers(startPos = [0,50,0], angle = 0, length = myWidth,edge=false, startCon=[2,2]);
        llFingers(startPos=[0,0,0], angle=90,length=myHeight,edge=true, startCon=[2,0]);
    }

    // side1
    llCutoutSquare(th = th, size=[myHeight,myDepth],pos=[th,0,0],ang=[0,-90,0]){
        llFingers(startPos=[0,0,0], angle=0, length = myHeight, edge=true, startCon=[0,0]);
        llFingers(startPos=[0,0,0], angle=90, length = myDepth, edge = true, startCon=[0,1]);
    }

    // test
    *anotherPice();
}

module testPice(){
    llCutoutSquare(th = th,size=[200,200], pos = [0,0], ang = [90,0,0]){
        fingerjoints(side = LEFT, type = OUTSIDE, count = 5);
        cutBlob(position = [100,100]){
            cube([40,40,th]);
        }
    }
}

module anotherPice(){
    llCutout(th = th, points = [[0,0],[0,100],[100,50],[100,0]], pos = [0,0], ang = [0,0]){
    }
}


