use <libs/function_helpers.scad>;

$fn = 16;

RCube2([10,5,6], [1,[0,0,0,2],0]);

module RCube2(size=[10,10,10],rounding=[0,[0,0,0,0],0],center=true) {
  //draws a solid cube which may have rounded edges
  // size = [x, y, z] /gives outer dimensions
  // rounding = [top rounding, [corner 1 rounding, c2r, c3r, c4r] bottom_rounding] /gives the radius for rounding the edges: all top or all bottom edges or individual vertical corners - ccw from top left

  x=size[0];
  y=size[1];
  z=size[2];

  r_z=[ rounding[0] < 0.1 ? 0.09 : rounding[0] , rounding[2] < 0.1 ? 0.09 : rounding[2] ];
  r_mid=[ 
          rounding[1][0] < 0.1 ? 0.09 : rounding[1][0] , 
          rounding[1][1] < 0.1 ? 0.09 : rounding[1][1] , 
          rounding[1][2] < 0.1 ? 0.09 : rounding[1][2] , 
          rounding[1][3] < 0.1 ? 0.09 : rounding[1][3] 
        ];
  
  xyz_uncenter = (center) ? [0,0,0] : [x/2,y/2,z/2];

  ctm=[
    //the top four corners - [x, y, z] each with the factors for [whole term, xy-or-z, r]
    [
      [ [ -1, 1/2, -1 ], [  1, 1/2, -1 ], [  1, 1/2, -1 ] ],
      [ [ -1, 1/2, -1 ], [ -1, 1/2, -1 ], [  1, 1/2, -1 ] ],
      [ [  1, 1/2, -1 ], [ -1, 1/2, -1 ], [  1, 1/2, -1 ] ],
      [ [  1, 1/2, -1 ], [  1, 1/2, -1 ], [  1, 1/2, -1 ] ]
    ],
    //the bottom four corners
    [
      [ [ -1, 1/2, -1 ], [  1, 1/2, -1 ], [ -1, 1/2, -1 ] ],
      [ [ -1, 1/2, -1 ], [ -1, 1/2, -1 ], [ -1, 1/2, -1 ] ],
      [ [  1, 1/2, -1 ], [ -1, 1/2, -1 ], [ -1, 1/2, -1 ] ],
      [ [  1, 1/2, -1 ], [  1, 1/2, -1 ], [ -1, 1/2, -1 ] ]
    ]
  ];
  
  translate(xyz_uncenter) {
    if ( r_z[0] < 0.1 && r_z[1] < 0.1 && r_mid[0] < 0.1 && r_mid[1] < 0.1 && r_mid[2] < 0.1 && r_mid[3] < 0.1 ) {
      cube([x,y,z],true);
    } else {
      hull() {
        //CrossBox(x,y,z,2); /not needed
        for (lv = [0:1]) { 
          for (cr = [0:3]) {
            echo("l:",lv, "c:",cr, "ctm:",ctm[lv][cr], "r_z:",r_z[lv], "r_mid:",r_mid[cr]);
            translate([ ctm[lv][cr][0][0] * (x * ctm[lv][cr][0][1] + (r_mid[cr] < 0.1 ? r_z[lv] : r_mid[cr]) * ctm[lv][cr][0][2]),  
                        ctm[lv][cr][1][0] * (y * ctm[lv][cr][1][1] + (r_mid[cr] < 0.1 ? r_z[lv] : r_mid[cr]) * ctm[lv][cr][1][2]), 
                        ctm[lv][cr][2][0] * (z * ctm[lv][cr][2][1] + r_z[lv]    * ctm[lv][cr][2][2]) ]) RCubeCorner(r_z[lv], r_mid[cr]);
          }
        }
      } 
    }
  }
}

module RCubeCorner(r_z, r_xy) {
  //creates an geometrical form which has a rounding along the z-axis and a differnet rounding along the xy-axis
  // r_z = radius of rounding along z-axis - values < 0.1 are interpreted as 0
  // r_xy = radius of rounding along xy-axis - values < 0.1 are interpreted as 0
  echo("running RCubeCorner(r_z, r_xy)", "r_z:",r_z, "r_xy:",r_xy);
  if ( r_z < 0.1 ) {
    //no z rounding
    if ( r_xy < 0.1 ) {
      //no xy rounding
      echo("this one");
      cube([r_xy*2,r_xy*2,r_z],true);
    } else {
      //with xy_rounding
      cylinder(r_z,r_xy,r_xy, true);
    }
  } else {
    //with z rounding
    if ( r_z == r_xy ) {
      //z and xy rounding same value
      sphere(r_z);
    } else if ( r_z <= r_xy ) {
      TorusOuterHalf( r_z, r_xy );
    } else if ( r_xy < 0.1 ) {
      //translate([r_z-r_xy/2,-r_z+r_xy/2,0]) 
      intersection() {
        rotate([0,90,0]) cylinder(2*r_z,r_z,r_z,true);
        rotate([90,0,0]) cylinder(2*r_z,r_z,r_z,true);
      }
    } else {
      echo("r_z:",r_z, "r_xy:",r_xy);
      assert(true,"cannot create a RCubeCorner element for given r_z and r_xy"); 
    }
  }
}

module Torus(r1, r2) {
  //creates a torus
  // r1 = radius of the edge of the torus
  // r2 = radius of the torus itself
  assert_greater_or_equal(r2/2,r1,"r1 > r2/2 in Torus");

  r_torus = r1;           // Radius   of  Torus
  r_total = r2 - r1;     // Radius   of  Torus overall 
    
  rotate_extrude(convexity = 10) // the value is the sides the finer
    translate([r_total, 0, 0])
      circle(r_torus); // the value is the sides
}

module TorusOuterHalf(r1, r2) {
  //creates a torus-like shape based on the outer half circle of what a torus would be based of
  //(bad explanation I know - create one and you'll understand)
  // r1 = radius of the edge of the torus
  // r2 = radius of the torus itself
  
  //echo("running TorusOuterHalf(r1, r2)", "r1:",r1, "r2:",r2);
  assert_greater_or_equal(r2,r1,"r1 > r2 in TorusOuterHalf");
  
  r_torus = r1;
  r_total = r2 - r1;
    
  rotate_extrude(convexity = 10) { // the value is the sides the finer
    translate([r_total, 0, 0]) {
      difference() {
        circle(r_torus);
        translate([-r_torus,0,0]) square([r_torus*2,r_torus*2], true);
      }
    }
  }
}


module CrossBox(x,y,z,r) {
	cube(size=[x-2*r,y-2*r,z],center=true);
	cube(size=[x-2*r,y,z-2*r],center=true);
	cube(size=[x,y-2*r,z-2*r],center=true);
}