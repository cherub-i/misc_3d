use <../libs/function_helpers.scad>;
include <../libs/object_helpers.scad>;


module strut(length=200, wst_cardboard=1.5, ends=2) {
  str_triangle = 20;
  edge_width = wst_cardboard;


  difference(){
    translate([wst_cardboard,wst_cardboard,0])
      linear_extrude(length) {
        rotate([0,0,180])
          translate([-edge_width,-edge_width,0]) {
            polygon([[0,0],[wst_cardboard+edge_width,0],[0,wst_cardboard+edge_width]]); //flat edges
            //square(wst_cardboard+edge_width, false); //sharp edges
          }
        polygon([[0,0], [0,str_triangle], [str_triangle,0]]);
      }
      
    if ( ends>0 ) {
      rotate([0,-45,0])
        translate([+str_triangle,0,-str_triangle])
          cube(2*str_triangle, true);
      rotate([45,0,0])
        translate([0,+str_triangle,-str_triangle])
          cube(2*str_triangle, true);
      if ( ends > 1 ) {
        translate([0,0,length]) {
          rotate([0,-45,0])
            translate([+str_triangle,0,-str_triangle])
              cube(2*str_triangle, true);
          rotate([45,0,0])
            translate([0,+str_triangle,-str_triangle])
              cube(2*str_triangle, true);
        }
      }
    }
  } 
}

strut(300,1.5,2);
//translate([0,1,0])
  //rotate([0,0,-90]) rotate([0,-90,0]) strut();
//translate([1,0,0])
  //rotate([0,90,0]) rotate([0,0,90]) strut();