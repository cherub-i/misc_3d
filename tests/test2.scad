use <../libs/function_helpers.scad>;
include <../libs/object_helpers.scad>;

$fn=30;


//z=3; xy=0;  // | >0  |  0   |             | cylinder       | 2*r_z  | fallb   |
//z=3; xy=3;  // | >0  | >0   | r_z == r_xy | sphere         | 2*r_z  | 2*r_xy  |
//z=4; xy=1;  // | >0  | >0   | r_z >= r_xy | TorusOutHalf   | 2*r_z  | 2*r_xy  |
//z=1; xy=2;  // | >0  | >0   | r_z < r_xy  | NOT SUPPORTED  | n/a    | n/a     |
//z=0; xy=3;  // |  0  | >0   |             | inters. cyls.  | fallb  | 2*r_xy  |
//z=0; xy=0;  // |  0  |  0   |             | cube           | fallb  | fallb   |

//diff=0.01;
//color("red") CrossBox(2*z-diff,2*z-diff,2*xy-diff,0);

//RCubeCorner(3,3);
//translate([4,0,0]) 
//RCubeCorner(0,3);


//SCube(20,20,20,0.5,5,"sides","topbottom");
//SCube2([20,20,20],0.5,[0,[5,5,5,0],1],"top");

/*
//for ( sx = [-100:25:100] ) {
  //for (sy = [-100:25:100] ) {
    translate([sx,sy,0]) {
      color("red") CrossBox(2,2,2,0.2);
      RCube2([2,2,2],[0.1,[0,0,0,0],0.1]);
    }
  //}
//}
*/

LiddedBox2([150,200,70],27,1.8,"box",[5,[36,25,25,25],0]);