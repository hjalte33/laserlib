# laserlib
A library to design lasercut objects in open scad. The library tries to be as flexible as possible by implementing all features as modifier modules.
There is no need for any external scripts to make this work. Just flip a single boolean after designing and you get all your objects positioned and packed flat. 

## Todo
 - [x] Finger joints
 - [x] Kerf compensation
 - [x] Clips
 - [x] Semi-automatic flat packing 
 - [ ] Living hinge (The function is there but not fully integrated yet) 
 - [ ] Fully Automatic packing of objects (might be imposible with current implementation.)

## Special Variables
 - ```$flatPack``` Bolean to toggle position of the lasercut objects. If true the position of all objects will be ignored and they will all be placed flat.
If false they will be placed where specified in ```llPos()```  
 - ```$kerf``` The thickness of the laser beam. Adjust to make a tight fit.  
 - ```$spacing``` The space between objects when packed flat.
 - ```$th```  The thicknes of the material. Is passed down througout the modifiers.  
 - ```$pos``` The position of the object. Is modified and set by ```llFlatPack()``` to position the object either in place or in its flat position.   
 - ```$ang``` The angle of the object. Is modified and set by ```llFlatPack()``` to angle the object in place or in its flat orientation.  

## Design Work Flow
This library works with the idea that you start with a shape like a square and the cut away or add features to that shape by using modifiers.
The function ```llCutoutSquare(size=[x,y])``` is a handy way to get a simple rectangular shape you can work with. If you need more complicated shapes you can also use
```llCutout(points=[])``` or make your own using the special variables described above. 
Afterwards the object is modified using ```llFingers()``` or the like. Finally the objects is placed and oriented using ```llPos```, ```llTranslate``` or ```llRotate```.   
Finally a group of objecs are organized using ```llFlatPack(x=0, sizel=[obj1, obj2, ...]){...}``` that depending on the value ```$flatPack``` alters the position of its child objecs so they either lay flat or is positioned as specified

## Examples
Finger joints:
```openscad
llFlatPack(x=0, sizes=[my_depth]){
  llPos(pos=[x,y,z],ang=[x,y,z], th=materialThickness){
  
    llFingers(startPos=[0,0], length=my_width, angle=0, startCon=[1,1],edge="r")                      // botom
      llFingers(startPos=[0,my_depth], length=box_depth, angle=-90, startCon=[0,0],edge="r")          // left side
        llFingers(startPos=[my_width,0], endPos=[my_width, my_height], startCon=[1,1],edge="r")       // right side
          llFingers(startPos=[0,my_depth-$th], length=box_height, angle=0, startCon=[0,0],edge="l")   // top
            llCutoutSquare([my_width,my_depth]){                                                      // the square
                translate([x,y,z])blobsToCutOut();                                                    // some custom blob to cutout of the square
            }
  }
  
}
```

