////////////////////////////////////////////////////////////////////////////////////////////////////
// copyright by Bastian Baumeister | openscad@bastianbaumeister.de 
// endcap for power supply unit
////////////////////////////////////////////////////////////////////////////////////////////////////
use <libs/function_helpers.scad>;
include <libs/object_helpers.scad>;

$fa = 5;

//power supply endcap
w_cap=100; //w, h, d are inner measurements!
h_cap=50;
d_cap=70;
wst_cap=1;


//plug-position - using variables, so I can move the plug including the screw holes and switch
plug_x=77;
plug_y=39;

//xt60 position
xt60_x=7;
xt60_y=16;


//generate outer measurements
x_cap=w_cap+2*wst_cap;
y_cap=h_cap+2*wst_cap;
z_cap=d_cap+1*wst_cap;

//amount of mm the mid of the screw-holes need to be positioned inwards from the endpoint of the endcap
screws_in=4;

cutouts_cap=[
  ["rect", "bottom", [plug_x,plug_y], wst_cap, [28,20], true], //plug
  ["circle", "bottom", [plug_x-20,plug_y], wst_cap, 2, true], //plug screw 
  ["circle", "bottom", [plug_x+20,plug_y], wst_cap, 2, true], //plug screw
  //["rect", "bottom", [0,0], wst_cap, [31,22.5], false], //switch
  ["rect", "bottom", [plug_x,plug_y-24.5], wst_cap, [31,22.5], true], //switch
  ["circle", "bottom", [13,41], wst_cap, 12, true], //banana plug
  ["circle", "bottom", [31,41], wst_cap, 12, true], //banana plug
  ["rect", "bottom", [xt60_x,xt60_y], wst_cap, [18.5,11], false], //xt60 cutout
  ["circle", "left", [13,z_cap-screws_in], wst_cap, 4, true], //screw hole
  ["circle", "left", [46,z_cap-screws_in], wst_cap, 4, true], //screw hole    
  ["circle", "right", [y_cap-13,z_cap-screws_in], wst_cap, 4, true], //screw hole
  ["circle", "right", [y_cap-46,z_cap-screws_in], wst_cap, 4, true], //screw hole    
];

module xt60_out() {
  translate([18.5/2,11/2,18/2]) {
    difference() {
      cube([18.5,11,18],true);
      
      //cut out core part on full height
      cube([15.5,8,18],true);
      
      //cut out more towards the outer part
      translate([0,0,-7])
        cube([16.5,9,9],true);
      
      //finally add a smooth edge to improve printability
      translate([0,0,-2.5])
        PyramidStump([16.5, 9, 3], 3);    
    }
  }
}


SCube(x_cap,y_cap,z_cap,wst_cap,r=0,rtype="none",otype="top",center=true,cutouts=cutouts_cap);
//add ridge to keep it from slipping inwards to much
translate([0,0,5])
  difference() {
    cube([x_cap,y_cap,3*wst_cap],true);
    translate([0,0,-1.5*wst_cap])
      PyramidStump([w_cap, h_cap, 3*wst_cap], 2);
  }
//xt60
translate([-x_cap/2+xt60_x,y_cap/2-xt60_y-11,-z_cap/2])  
  xt60_out();