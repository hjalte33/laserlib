include <laserlib.scad>;

th = 6; // thikness

$flatPack = true;  // Toggle for whether or not to flatpack you build
$spaceing = 2;     // When flatpacking 

myWidth = 100;
my height = 115;


llFlatPack(x = 0 , sizes=[110,100,200]){

    // front
    llCutoutSquare(th = 5, size=[100,100],pos=[10,0,40],ang=[90,0,0]){
        llFingers(startPos = [0,0,0], angle = 0, length = 100,edge=true, startCon=2);
        llFingers(startPos = [0,50,0], angle = 0, length = 100,edge=true, startCon=1);
    }

    // back

    llCutout(th = 5, points = [[0,0],[100,0],[100,100],[0,100]],pos=[10,0,30],adderChildren=[]){
        *llTest(0,30);
        fingers(angle=0, start_up=0, fingers=6, thickness=5, range_min=0, range_max=100, t_x=0, t_y=0, bumps = false);
        fingers(angle=90, start_up=0, fingers=6, thickness=5, range_min=0, range_max=100, t_x=0, t_y=0, bumps = false);
        fingers(angle=-90, start_up=0, fingers=6, thickness=5, range_min=0, range_max=100, t_x=100, t_y=100, bumps = false);
        
    }
    llCutout(th = 5, points = [[0,0],[50,0],[100,100],[0,100]],pos=[10,0,30],ang=[0,-90,0]){
    }
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
        fingerjoints(side = DOWN, type = INSIDE, count = 5);
    }
}


