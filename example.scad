include <lasercut.scad>;

th = 6

lasercutFlatPack(){
    testPice()
    onetherPice()
}


module testPice(){
    lasercutoutSquare2(th = th,size=[200,200], pos = [0,0], ang = [90,0,0]){
        fingerjoints(side = LEFT, type = OUTSIDE, count = 5);
        cutBlob(position = [100,100]){
            cube([40,40,th]);
        }
    }
}

module anotherPice(){
    lasercutout2(th = th, points = [[0,0],[0,100],[100,50],[100,0]], pos = [0,0], ang = [0,0]){
        fingerjoints(side = DOWN, type = INSIDE, count = 5)
    }
}