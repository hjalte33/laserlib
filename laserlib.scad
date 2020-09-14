
$flatPack = true;
$spaceing = 2;

flatPack(x = 0 , sizes=[110,100,200]){
    lasercutout2(th = 5, points = [[0,0],[100,0],[100,100],[0,100]],pos=[10,0,40],ang=[90,0,0]){
        testing();
    }

    lasercutout2(th = 5, points = [[0,0],[100,0],[100,100],[0,100]],pos=[10,0,30],adderChildren=[]){
        *testing(0,30);
        fingers(angle=0, start_up=1, fingers=5, thickness=5, range_min=0, range_max=100, t_x=0, t_y=0, bumps = false);
        
    }
    lasercutout2(th = 5, points = [[0,0],[50,0],[100,100],[0,100]],pos=[10,0,30],ang=[0,-90,0]){
    }
}


/*
slice slices an array from start to end. 
v = [... , ]  --> array to be sliced 
start = int   --> start index 
end   = int   --> end index. if 0 it slices to the end of the array.
*/
function slice(v,start,end=0) = 
    end ? [for (i=[start:1:end]) v[i]] 
        : [for (i=[start:1:len(v)-1]) v[i]];



// Create a simple recursive function that adds the values of a list of floats;
// the simple tail recursive structure makes it possible to
// internally handle the calculation as loop, preventing a
// stack overflow.
function add(v, i = 0, end = 0, r = 0) = 
    let(iend = end ? end : len(v))
    i < end ? add(v, i + 1, end, r + v[i]) : r;


/*
flatPack packs all children elements along the y axis. at a given x offest.
The Special valiable $pos instructs all children elements to use that position instead
of whatever position it might have

x = float  --> position along x axis to stack the elemenst at 

sizes = [float, ...]  --> array of all the sizes of the children ( in the y direction only). 
This is nessesary in order to stack the elements with the correct distance to each other. 
There is no other neat way to get the size og the children elements without explicitly 
passing it in. 

spaceing = float  --> space between the parts. 
*/
module flatPack(x = 0, sizes=[], spaceing = 2){
    for(i=[0:1:$children-1]){
        $pos = [x,add(sizes,0,i)+i*spaceing,0];
        children(i);
    }
}


module lasercutoutSquare2(th = th,size=[100,100], pos = [0,0,0], ang = [0,0,0]){
    points = [[0,0], [size[0],0], [size[0],size[1]], [0,size[1]], [0,0]];
    lasercutout2(th = th, points = points, pos = pos, ang = ang){
        children();
    }
}

module lasercutout2(th, points = [], pos = [0,0,0], ang = [0,0,0],adderChildren=[]){
    pos = $flatPack ? $pos    : pos;
    ang = $flatPack ? [0,0,0] : ang;
    $th = th;   
    
    translate(pos) rotate(ang){
        difference(){
            linear_extrude(height = th , center = false)  polygon(points=points);
            for(i=[0:1:$children-1]) if ( ! search(i,adderChildren)){
                children(i);
            }
        }
        for(i = adderChildren) children(i);

    }
    
}

module testing(x=0, y=0,z=0){
    translate([x,y,z]) cube([100,50,10]);
}
