

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
flatPack packs all children elements along the y axis. at a given x offset.
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
        $pos = 0;   // has to be assigned something so zero will do
        children();
    }

}

module llPos(pos,ang, th){
    pos = $flatPack ? $pos    : pos;
    ang = $flatPack ? [0,0,0] : ang;
    $th = th;   
    
    // Put the cutout into position 
    translate(pos) rotate(ang){
        children();
    }
} 

module llCutoutSquare(size=[100,100], th=$th){
    points = [[0,0], [size[0],0], [size[0],size[1]], [0,size[1]], [0,0]];
    llCutout(th = th, points = points){
        if($children > 0 ) children(0);
        if($children > 1) children(1);
    }
}

module llCutout(th, points = []){
    difference(){
        linear_extrude(height = th , center = false)  polygon(points=points);
        children(0);
    }
    if($children > 1) children(1);
}

module llIgnore(){
    if (! $flatPack){
        children();
    }
}

module llBlobCut(pos){
    difference(){       
        children([1:$children-1]);
        translate(pos)children(0);
    }
}

module llClip_old(startPos=[0,0,0],angle=0,mirror=false){
    mating_thickness = 6;
    me_thickness = 6;
    stickout = me_thickness;
    bend_factor = 9;

    module hole(){
        linear_extrude(me_thickness)
            polygon(points=[[me_thickness,0],
                            [me_thickness*2,me_thickness*bend_factor],
                            [me_thickness*3+0.1,me_thickness*bend_factor],
                            [me_thickness*3+0.1,0]]);
    }
    module clip(){
        translate([0,-mating_thickness,0]) cube([me_thickness,mating_thickness,me_thickness]);
        linear_extrude(me_thickness) 
            polygon(points=[[me_thickness*2,-mating_thickness-stickout],
                            [me_thickness*2,me_thickness*bend_factor],
                            [me_thickness*3,me_thickness*bend_factor],
                            [me_thickness*3,-mating_thickness],
                            [me_thickness*3.75,-mating_thickness],
                            [me_thickness*3.75,-mating_thickness-1],
                            [me_thickness*3,-mating_thickness-stickout]]);
    }

    if (mirror){
        offset=[me_thickness*2+stickout,0,0];
        difference(){
            children()
            translate(startPos+offset)rotate([0,0,angle])mirror([1,0,0])hole();
        }
        
        translate(startPos+offset)rotate([0,0,angle]) mirror([1,0,0])clip();
    }else{
        difference(){
            children()
            translate(startPos)rotate([0,0,angle]) hole();
        }
        
        translate(startPos)rotate([0,0,angle]) clip();
    }
}

module llClipHole(startPos=[0,0,0], angle = 0, mating_thickness = $th, mirror = false){
    latch_fraction = 0.3;
    latch_length = mating_thickness*latch_fraction;
    hkerf = $kerf/2;

    difference(){
        children();
        if(mirror){
            translate(startPos+[-hkerf,hkerf,0])rotate([0,0,angle])mirror([1,0,0])cube([mating_thickness*2+latch_length-$kerf,mating_thickness-$kerf, $th]);
        }
        else{
            translate(startPos+[hkerf,hkerf,0])rotate([0,0,angle])cube([mating_thickness*2+latch_length-$kerf,mating_thickness-$kerf, $th]);
        }
    }

}

module llClip(startPos = [0,0,0], angle = 0, mating_thickness = $th, mirror = false){
    stickout = $th/3;
    hinge_depth = 2*$th;
    hinge_length = 2*$th;
    latch_fraction = 0.3;
    latch_length = $th*latch_fraction;

    module hole(){
        linear_extrude($th)
            polygon(points=[[$th,0],
                            [$th,hinge_depth/2-0.1],
                            [$th-latch_length*2,hinge_depth/2-0.1],
                            [$th,hinge_depth+0.1],
                            [hinge_length+$th*2+latch_length,hinge_depth+0.1],
                            [hinge_length+$th*2+latch_length,0]]);
    }

    module clip(){
        // the clip
        translate([0,-mating_thickness,0]) cube([$th,mating_thickness,$th]);
        linear_extrude($th) 
            polygon(points=[[$th+latch_length,-mating_thickness-stickout],
                            [$th-latch_length/2,-mating_thickness-1],
                            [$th-latch_length/2,-mating_thickness-0.1],
                            [$th+latch_length,-mating_thickness-0.1],
                            [$th+latch_length,hinge_depth/2],
                            [$th-latch_length,hinge_depth/2],
                            [$th+latch_length,hinge_depth],
                            [$th*2+latch_length,hinge_depth],
                            [$th*2+latch_length,-mating_thickness],
                            [$th*2+latch_length*2,-mating_thickness],
                            [$th*2+latch_length*2,-mating_thickness-1],
                            [$th*2+latch_length,-mating_thickness-stickout]]);
        
        // slight offset the size to make things union correctly
        translate([$th*2+latch_length-0.005,0]) 
            llHinge(size_x = hinge_length+0.01,mat_x=0.8,mat_y=1.2, size_y=hinge_depth,num_holes_x = 12.5, num_holes_y = 2, center=false, $th = 6);
    }

    if (mirror){
        difference(){
            children();
            translate(startPos)rotate([0,0,angle]) mirror([1,0,0])hole();
        }
        
        translate(startPos)rotate([0,0,angle]) mirror([1,0,0])clip();
    }else{
        difference(){
            children();
            translate(startPos)rotate([0,0,angle]) hole();
        }
        
        translate(startPos)rotate([0,0,angle]) clip();
    }

}

module llFingers(startPos, endPos=[], angle=0, length=0, nFingers = 0, edge = false, startCon = [1,3], holeWidth = 0, specialWidths=[]){

    difference(){
        children(0);
        f();
    }

    module f(){    
        // if a length and angle is supplied calculate the end Possition 
        endPos = length ? [startPos[0] + cos(angle)*length, startPos[1] + sin(angle)*length ] : endPos ;

        // Calculate the length and angle if endPos is given
        function _length() = sqrt(pow(endPos[0] - startPos[0], 2) + pow(endPos[1] - startPos[1], 2));
        function _angle()  = atan2(endPos[1] - startPos[1], endPos[0] - startPos[0]);

        // Width of fingers. Set the holewidth to the material thikness if nothing else specified. 
        wH = holeWidth ? holeWidth : $th;
        
        // number of fingers
        nH = nFingers ? nFingers : floor(_length()/20); // should give approx between 10 and 20 mm length tabs

        // Half $kerf   this is useful in calculations
        hkerf = $kerf/2;

        // Sizes for mating cuts on the edge if the first/last tab meets a different thickness material.
        sW = specialWidths ? specialWidths : [wH,wH];   

        module holes(){

            if(startCon == [0,0]){
                // remove the first little kerf leftover
                if(edge) translate([-hkerf,0,0]) punchHoles(1,hkerf*3,wH,edge);
                
                lH = _length()/(nH*2-1);
                punchHoles(nH,lH,wH,edge);

                // remove the end littel kerf leftover.
                if (edge) translate([_length()-$kerf-hkerf,0]) punchHoles(1,$kerf*2,wH,edge);
            }
            else if(startCon == [0,1]){
                // remove the first little kerf leftover
                if(edge) translate([-hkerf,0,0]) punchHoles(1,hkerf*3,wH,edge);
                
                lH = (_length()) / (nH*2);
                punchHoles(nH,lH,wH,edge);
            }
            else if(startCon == [0,2]){
                // remove the first little kerf leftover
                if(edge) translate([-hkerf,0,0]) punchHoles(1,hkerf*3,wH,edge);
                
                lH = (_length() - sW[1]) / (nH*2-2);
                punchHoles(nH-1,lH,wH,edge);

                // remove the end cutout
                if (edge) translate([_length()-sW[1],0]) punchHoles(1,sW[1]+hkerf,wH,edge);
            }
            else if(startCon == [0,3]){
                // remove the first little kerf leftover
                if(edge) translate([-hkerf,0,0]) punchHoles(1,hkerf*3,wH,edge);
                
                lH = (_length() - sW[1]) / (nH*2-1);
                punchHoles(nH,lH,wH,edge);

          
            }
            else if(startCon == [1,0]){
                lH = _length()/(nH*2);
                translate([lH,0,0]) punchHoles(nH,lH,wH,edge);

                // remove the end littel kerf leftover.
                if (edge) translate([_length()-$kerf-hkerf,0]) punchHoles(1,$kerf*2,wH,edge);
            }
            else if(startCon == [1,1]){          
                lH = (_length()) / (nH*2-1);
                translate([lH,0,0])punchHoles(nH-1,lH,wH,edge);
            }
            else if(startCon == [1,2]){          
                lH = (_length() - sW[1]) / (nH*2-1);
                translate([lH,0,0]) punchHoles(nH-1,lH,wH,edge);

                // remove the end cutout
                if (edge) translate([_length()-sW[1],0]) punchHoles(1,sW[1]+hkerf,wH,edge);
            }
            else if(startCon == [1,3]){          
                lH = (_length() - sW[1]) / (nH*2-2);
                translate([lH,0,0]) punchHoles(nH-1,lH,wH,edge);
            }
            else if(startCon == [2,0]){
                // remove the first little kerf leftover
                if(edge) translate([-hkerf,0,0]) punchHoles(1,sW[0]+hkerf,wH,edge);
                
                lH = (_length()-sW[0])/(nH*2-2);
                translate([sW[0]+lH,0,0]) punchHoles(nH-1,lH,wH,edge);

                // remove the end littel kerf leftover.
                if (edge) translate([_length()-$kerf-hkerf,0]) punchHoles(1,$kerf*2,wH,edge);
            }
            else if(startCon == [2,1]){
                // remove the first little kerf leftover
                if(edge) translate([-hkerf,0,0]) punchHoles(1,sW[0]+hkerf,wH,edge);
                
                lH = (_length()-sW[0])/(nH*2-1);
                translate([sW[0]+lH,0,0]) punchHoles(nH-1,lH,wH,edge);

            }
            else if(startCon == [2,2]){
                // remove the first little kerf leftover
                if(edge) translate([-hkerf,0,0]) punchHoles(1,sW[0]+hkerf,wH,edge);
                
                lH = (_length()-sW[0]-sW[1])/(nH*2-3);
                translate([sW[0]+lH,0,0]) punchHoles(nH-2,lH,wH,edge);

                // remove the end cutout
                if (edge) translate([_length()-sW[1],0]) punchHoles(1,sW[1]+hkerf,wH,edge);           
            }
            else if(startCon == [2,3]){
                // remove the first little kerf leftover
                if(edge) translate([-hkerf,0,0]) punchHoles(1,sW[0]+hkerf,wH,edge);
                
                lH = (_length()-sW[0]-sW[1])/(nH*2-2);
                translate([sW[0]+lH,0,0]) punchHoles(nH-1,lH,wH,edge);          
            }
            else if(startCon == [3,0]){
                lH = (_length()-sW[0])/(nH*2-1);
                translate([sW[0],0,0]) punchHoles(nH,lH,wH,edge);

                // remove the end cutout
                if (edge) translate([_length()-sW[1],0]) punchHoles(1,sW[1]+hkerf,wH,edge);           
            }
            else if(startCon == [3,1]){
                lH = (_length()-sW[0])/(nH*2-2);
                translate([sW[0],0,0]) punchHoles(nH-1,lH,wH,edge);
        
            }
            else if(startCon == [3,2]){
                lH = (_length()-sW[0]-sW[1])/(nH*2-2);
                translate([sW[0],0,0]) punchHoles(nH-1,lH,wH,edge);

                // remove the end cutout
                if (edge) translate([_length()-sW[1],0]) punchHoles(1,sW[1]+hkerf,wH,edge);           
            }
            else if(startCon == [3,3]){
               
                lH = (_length()-sW[0]-sW[1])/(nH*2-3);
                translate([sW[0],0,0]) punchHoles(nH-1,lH,wH,edge);          
            }
            else{
                assert(false, "invalid start condition on fingerjoints");
            }
            
        }

        translate(startPos)rotatePoint(_angle(),[wH/2,wH/2,0]) holes();
            
    }    

}

module rotatePoint(a, point) {
    translate(point)
    rotate(a)
    translate(-point)
    children();
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
    edgeRightHolePoints = [[ hkerf   ,  -1    ,     -1 ],  //0
                          [ lH-hkerf ,  -1    ,     -1 ],  //1
                          [ lH-hkerf ,  wH-hkerf  ,     -1 ],  //2
                          [ hkerf   ,  wH-hkerf  ,     -1 ],  //3
                          [ hkerf   ,  -1    ,  $th+1 ],  //4
                          [ lH-hkerf ,  -1    ,  $th+1 ],  //5
                          [ lH-hkerf ,  wH-hkerf  ,  $th+1 ],  //6
                          [ hkerf   ,  wH-hkerf  ,  $th+1 ]]; //7
    
    edgeLeftHolePoints =  [[ hkerf   ,  hkerf    ,     -1 ],  //0
                          [ lH-hkerf ,  hkerf    ,     -1 ],  //1
                          [ lH-hkerf ,  wH+1  ,     -1 ],  //2
                          [ hkerf   ,  wH+1  ,     -1 ],  //3
                          [ hkerf   ,  hkerf    ,  $th+1 ],  //4
                          [ lH-hkerf ,  hkerf    ,  $th+1 ],  //5
                          [ lH-hkerf ,  wH+1  ,  $th+1 ],  //6
                          [ hkerf   ,  wH+1  ,  $th+1 ]]; //7

    for(i=[0:nH-1]){ 
        translate([i*lH*2,0]){
            if (edge == "l" || edge == "L") {polyhedron(edgeLeftHolePoints,holeFaces);}
            else if (edge == "r" || edge == "R") {polyhedron(edgeRightHolePoints,holeFaces);}
            else {polyhedron(holePoints,holeFaces);}
        }
    }

}


module llHinge(size_x = 50, 
               size_y = 100,
               num_holes_x = 13, 
               num_holes_y = 3, 
               mat_x = 2,
               mat_y = 3,
               min_hole_x = 1.5, 
               center=true){
    if ($children){
        difference(){
            children();
            cube([size_x,size_y,$th],center=center);
        }
    }
    h();
   
    module h(){
        $fn = 30;
        ep = 0.1;
        v_center=center?-[size_x,size_y,$th]/2:[0,0,0];//a vector for adjusting the center position
        
        num_holes_x = round(num_holes_x);

        sum_hole_width = size_x - mat_x*(num_holes_x-1);
        // calculate hole width
        hw = sum_hole_width/num_holes_x ;
        // depending on result set actual hole width and calculate the material thickness between holes.
        hole_width = hw < min_hole_x ? ep : hw;   
        mat_x = hw < min_hole_x ? size_x/num_holes_x : mat_x;
            
        sum_hole_length = size_y - mat_y*(num_holes_y+1);
        hole_length = sum_hole_length/(num_holes_y);
        
        translate(v_center) difference(){
            // create a square and cut out a bunch of holes to form the hinge
            cube([size_x,size_y,$th],center = false);
            
            //A hinge with hinges_across_length=2 should look like:
                // |----------  ------------------  ----------|
                // |  ------------------  ------------------  |
                // |----------  ------------------  ----------|
                // |  ------------------  ------------------  |
            
            // go chroug each of the major lines
            for (x=[0:num_holes_x-1]){
                translate([x*(mat_x+hole_width) + hole_width/2 ,0,0]){
                    
                    // go throug each of the individual cutouts. 
                    for(y=[0:num_holes_y]){
                        translate([0,y*(hole_length + mat_y) + mat_y - (x%2)*(hole_length/2+mat_y/2) , 0])   
                            // cutout a hole with nice rounded edges. 
                            hull(){
                                translate([0,hole_width/2]) cylinder($th, r = hole_width/2);
                                translate([0,hole_length-hole_width/2]) cylinder($th, r = hole_width/2);
                            };
                            
                    }
                }
            }        
        }  
    }
}


//////////////////////////////////////not used below ///////////////////



