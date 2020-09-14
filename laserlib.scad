
//ToDo remove this 
kerf = 0;

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
module llFlatPack(x = 0, sizes=[], spaceing = 2){
    if ($flatPack){
        projection(cut = false)
        for(i=[0:1:$children-1]){
            $pos = [x,add(sizes,0,i)+i*spaceing,0];
            children(i);
        }
    } else{
        $pos = 0;   
        children();
    }
}


module llCutoutSquare(th = th,size=[100,100], pos = [0,0,0], ang = [0,0,0],adderChildren=[]){
    points = [[0,0], [size[0],0], [size[0],size[1]], [0,size[1]], [0,0]];
    llCutout(th = th, points = points, pos = pos, ang = ang,adderChildren=[]){
        children();
    }
}

module llCutout(th, points = [], pos = [0,0,0], ang = [0,0,0],adderChildren=[]){
    pos = $flatPack ? $pos    : pos;
    ang = $flatPack ? [0,0,0] : ang;
    $th = th;   
    
    // Put the cutout into position 
    translate(pos) rotate(ang){
        // Extrude the cutout shape and substract all the children not marked 
        // as adding children 
        difference(){
            linear_extrude(height = th , center = false)  polygon(points=points);
            for(i=[0:1:$children-1]) if ( ! search(i,adderChildren)){
                children(i);
            }
        }
        // Add all the adder children
        for(i = adderChildren) children(i);

    }
    
}

module llTest(x=0, y=0,z=0){
    translate([x,y,z]) cube([100,50,10]);
}


module llFingers(startPos, angle, length, nFingers = 0, edge = false, startCon = 0, holeWidth = 0, kerf = 0.1){

    // Calculate the end Position
    endPos = [[cos(angle)*length,        0          ,0],
              [       0         , sin(angle)*length ,0]] * startPos;

    // Width of fingers. Set the holewidth to the material thikness if nothing else specified. 
    wF = holeWidth ? holeWidth : $th;
    
    // number of fingers
    nF = nFingers ? nFingers : floor(length/20); // gives between 10 and 20 mm length tabs

    // length of fingers
    lF = length/nF/2.0;
    echo(lF);

    // Half kerf
    hkerf = kerf/2;

    holeFaces = [
        [0,1,2,3],  // bottom
        [4,5,1,0],  // front
        [7,6,5,4],  // top
        [5,6,2,1],  // right
        [6,7,3,2],  // back
        [7,4,0,3]]; // left     
  
    holePoints = [[ hkerf   ,  hkerf    ,     -1 ],  //0
                  [ lF-kerf ,  hkerf    ,     -1 ],  //1
                  [ lF-kerf ,  wF-kerf  ,     -1 ],  //2
                  [ hkerf   ,  wF-kerf  ,     -1 ],  //3
                  [ hkerf   ,  hkerf    ,  $th+1 ],  //4
                  [ lF-kerf ,  hkerf    ,  $th+1 ],  //5
                  [ lF-kerf ,  wF-kerf  ,  $th+1 ],  //6
                  [ hkerf   ,  wF-kerf  ,  $th+1 ]]; //7
    
    edgeHolePoints = [[ hkerf   ,  -hkerf  ,     -1 ],  //0
                      [ lF-kerf ,  -hkerf  ,     -1 ],  //1
                      [ lF-kerf ,  wF-kerf ,     -1 ],  //2
                      [ hkerf   ,  wF-kerf ,     -1 ],  //3
                      [ hkerf   ,  -hkerf  ,  $th+1 ],  //4
                      [ lF-kerf ,  -hkerf  ,  $th+1 ],  //5
                      [ lF-kerf ,  wF-kerf ,  $th+1 ],  //6
                      [ hkerf   ,  wF-kerf ,  $th+1 ]]; //7

    // Hole punching rutine
    module punchHoles(){
        for(i=[0:nF]){
            translate([i*lF*2,0]){
                if (edge) {polyhedron(edgeHolePoints,holeFaces);}
                else {polyhedron(holePoints,holeFaces);}
            }
        }
    }

    // take care of the different starting conditions.
    if (startCon == 0){
        // take care of the first littel kerf left over on the edge
        if(edge) translate([0,0,-1])cube([kerf,wF,th+1]);
        translate(startPos) rotate([0,0,angle]) punchHoles();
    }
    else if(startCon == 1){
        translate(startPos+[lF/2,0,0]) rotate([0,0,angle]) punchHoles();
    }
    else if(startCon == 2){
        // take care of the last littel kerf left over on the edge
        if (edge) translate([length-kerf,0,-1])cube([kerf,wF,th+1]);
        // punch the holes
        translate(startPos+[lF,0,0]) rotate([0,0,angle]) punchHoles();

    }

}
















module fingers(angle, start_up, fingers, thickness, range_min, range_max, t_x, t_y, bumps = false)
{

    // The tweaks to y translate([0, -thickness,0]) ... thickness*2 rather than *1
    // Are to avoid edge cases and make the dxf export better.
    // All fun
    translate([t_x, t_y,0]) rotate([0,0,angle]) translate([0, -thickness,0])
    {
        for ( p = [ 0 : 1 : fingers-1] )
		{
		
			kerfSize = (p > 0) ? kerf/2 : kerf/2 ;
			kerfMove = (p > 0) ? kerf/4 : 0;
			
			i=range_min + ((range_max-range_min)/fingers)*p;
            if(start_up == 1) 
            {
			
                translate([i-kerfMove,0,0]) 
                {
                    cube([ (range_max-range_min)/(fingers*2) + kerfSize, thickness*2, thickness]);
                    if(bumps == true)
                    {
                        translate([(range_max-range_min)/(fingers*2), thickness*1.5, 0]) cylinder(h=thickness, r=thickness/10);
                    }
                }
            }
            else 
            {
                translate([i+(range_max-range_min)/(fingers*2)-kerfMove,0,0]) 
                {
                    cube([ (range_max-range_min)/(fingers*2)+kerfSize, thickness*2, thickness]);
                    if(bumps == true)
                    {
                        if (i < (range_max - (range_max-range_min)/fingers ))
                        {
                            translate([(range_max-range_min)/(fingers*2), thickness*1.5, 0]) cylinder(h=thickness, r=thickness/10);
                        }
                    }
                }
            }
        }
    }

}
