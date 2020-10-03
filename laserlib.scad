

$kerf = 0.5;

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


module llFingers(startPos, angle, length, endPos=[], nFingers = 0,inverse = false, edge = false, startCon = [1,3], holeWidth = 0, specialWidths=[]){
    
    // if a length and angle is supplied calculate the end Possition 
    // Make both end and start position specias variables;
    $endPos = length ? [cos(angle)*length, sin(angle)*length] : endPos ;
    $startPos = startPos;

    // Calculate the length and angle if endPos is given
    function _length() = sqrt(pow($endPos[0] - $startPos[0], 2) + pow($endPos[1] - $startPos[1], 2));
    function _angle()  = atan2($endPos[1] - $startPos[1], $endPos[0] - $startPos[0]);

    // Width of fingers. Set the holewidth to the material thikness if nothing else specified. 
    wH = holeWidth ? holeWidth : $th;
    
    // number of fingers
    nH = nFingers ? nFingers : floor(_length()/20); // should give approx between 10 and 20 mm length tabs
    echo(nH);

    // Half $kerf   this is useful in calculations
    hkerf = $kerf/2;

    // Sizes for mating cuts on the edge if the first/last tab meets a different thickness material.
    sW = specialWidths ? specialWidths : [wH,wH];   

    module holes(){

        if(startCon == [0,0]){
            // remove the first little kerf leftover
            if(edge) translate([-hkerf,0,0]) punchHoles(1,hkerf*3,wH,true);
            
            lH = _length()/(nH*2-1);
            punchHoles(nH,lH,wH,edge);

            // remove the end littel kerf leftover.
            if (edge) translate([_length()+hkerf,0]) rotate(180) punchHoles(1,$kerf*2,wH,true);
        }
        else if(startCon == [0,1]){
            // remove the first little kerf leftover
            if(edge) translate([-hkerf,0,0]) punchHoles(1,hkerf*3,wH,true);
            
            lH = (_length()) / (nH*2);
            punchHoles(nH,lH,wH,edge);
        }
        else if(startCon == [0,2]){
            // remove the first little kerf leftover
            if(edge) translate([-hkerf,0,0]) punchHoles(1,hkerf*3,wH,true);
            
            lH = (_length() - sW[1]) / (nH*2-2);
            punchHoles(nH-1,lH,wH,edge);

            // remove the end cutout
            if (edge) translate([_length()+hkerf,0]) rotate(180) punchHoles(1,sW[1]+hkerf,wH,true);
        }
        else if(startCon == [1,0]){
            lH = _length()/(nH*2);
            translate([lH,0,0]) punchHoles(nH,lH,wH,edge);

            // remove the end littel kerf leftover.
            if (edge) translate([_length()+hkerf,0]) rotate(180) punchHoles(1,$kerf*2,wH,true);
        }
        else if(startCon == [1,1]){          
            lH = (_length()) / (nH*2+1);
            translate([lH,0,0])punchHoles(nH,lH,wH,edge);
        }
        else if(startCon == [1,2]){          
            lH = (_length() - sW[1]) / (nH*2-1);
            translate([lH,0,0]) punchHoles(nH-1,lH,wH,edge);

            // remove the end cutout
            if (edge) translate([_length()+hkerf,0]) rotate(180) punchHoles(1,sW[1]+hkerf,wH,true);
        }
        else if(startCon == [2,0]){
            // remove the first little kerf leftover
            if(edge) translate([-hkerf,0,0]) punchHoles(1,sW[0]+hkerf,wH,true);
            
            lH = (_length()-sW[0])/(nH*2-2);
            translate([sW[0]+lH,0,0]) punchHoles(nH-1,lH,wH,edge);

            // remove the end littel kerf leftover.
            if (edge) translate([_length()+hkerf,0]) rotate(180) punchHoles(1,$kerf*2,wH,true);
        }
        else if(startCon == [2,1]){
            // remove the first little kerf leftover
            if(edge) translate([-hkerf,0,0]) punchHoles(1,sW[0]+hkerf,wH,true);
            
            lH = (_length()-sW[0])/(nH*2-1);
            translate([sW[0]+lH,0,0]) punchHoles(nH-1,lH,wH,edge);

        }
        else if(startCon == [2,2]){
            // remove the first little kerf leftover
            if(edge) translate([-hkerf,0,0]) punchHoles(1,sW[0]+hkerf,wH,true);
            
            lH = (_length()-sW[0]-sW[1])/(nH*2-3);
            translate([sW[0]+lH,0,0]) punchHoles(nH-2,lH,wH,edge);

            // remove the end cutout
            if (edge) translate([_length()+hkerf,0]) rotate(180) punchHoles(1,sW[1]+hkerf,wH,true);           
        }
        else{
            assert(false, "invalid start condition on fingerjoints");
        }
        
    }

    rotate([0,0,_angle()]) {
        if(inverse){
            
            difference(){
                translate(startPos + [0,-wH+hkerf,-1]) cube([_length(), wH*2-$kerf, $th+2]); 
                    
                holes();
            }
        } else{
            holes();
        }
    }
    

}

// Hole punching rutine
module punchHoles(nH,lH,wH,edge){
    hkerf=$kerf/2;

    holeFaces = [
        [0,1,2,3],  // bottom
        [4,5,1,0],  // front
        [7,6,5,4],  // top
        [5,6,2,1],  // right
        [6,7,3,2],  // back
        [7,4,0,3]]; // left     

    holePoints = [[ hkerf   ,  hkerf    ,     -1 ],  //0
                  [ lH-hkerf ,  hkerf    ,     -1 ],  //1
                  [ lH-hkerf ,  wH-hkerf  ,     -1 ],  //2
                  [ hkerf   ,  wH-hkerf  ,     -1 ],  //3
                  [ hkerf   ,  hkerf    ,  $th+1 ],  //4
                  [ lH-hkerf ,  hkerf    ,  $th+1 ],  //5
                  [ lH-hkerf ,  wH-hkerf  ,  $th+1 ],  //6
                  [ hkerf   ,  wH-hkerf  ,  $th+1 ]]; //7
    
    // double widths make the rotation easier. 
    edgeHolePoints = [[ hkerf   ,  -wH+hkerf ,     -1 ],  //0
                      [ lH-hkerf ,  -wH+hkerf ,     -1 ],  //1
                      [ lH-hkerf ,  wH-hkerf   ,     -1 ],  //2
                      [ hkerf   ,  wH-hkerf   ,     -1 ],  //3
                      [ hkerf   ,  -wH+hkerf ,  $th+1 ],  //4
                      [ lH-hkerf ,  -wH+hkerf ,  $th+1 ],  //5
                      [ lH-hkerf ,  wH-hkerf   ,  $th+1 ],  //6
                      [ hkerf   ,  wH-hkerf   ,  $th+1 ]]; //7


    for(i=[0:nH-1]){ 
        translate([i*lH*2,0]){
            if (edge) {polyhedron(edgeHolePoints,holeFaces);}
            else {polyhedron(holePoints,holeFaces);}
        }
    }

}










//////////////////////////////////////not used below ///////////////////






module fingers(angle, start_up, fingers, thickness, range_min, range_max, t_x, t_y, bumps = false)
{

    // The tweaks to y translate([0, -thickness,0]) ... thickness*2 rather than *1
    // Are to avoid edge cases and make the dxf export better.
    // All fun
    translate([t_x, t_y,0]) rotate([0,0,angle]) translate([0, -thickness,0])
    {
        for ( p = [ 0 : 1 : fingers-1] )
		{
		
			$kerfSize = (p > 0) ? $kerf/2 : $kerf/2 ;
			$kerfMove = (p > 0) ? $kerf/4 : 0;
			
			i=range_min + ((range_max-range_min)/fingers)*p;
            if(start_up == 1) 
            {
			
                translate([i-$kerfMove,0,0]) 
                {
                    cube([ (range_max-range_min)/(fingers*2) + $kerfSize, thickness*2, thickness]);
                    if(bumps == true)
                    {
                        translate([(range_max-range_min)/(fingers*2), thickness*1.5, 0]) cylinder(h=thickness, r=thickness/10);
                    }
                }
            }
            else 
            {
                translate([i+(range_max-range_min)/(fingers*2)-$kerfMove,0,0]) 
                {
                    cube([ (range_max-range_min)/(fingers*2)+$kerfSize, thickness*2, thickness]);
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
