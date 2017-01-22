use <libs/function_helpers.scad>;
include <libs/object_helpers.scad>;

$fa = 5;

//eb185 box
x_box=250;
y_box=250;
z_box=90;
lid_z_box=30;
//r_box=0;
r_box=25;
t_box="all";
wst_box=3;

x_box_inside=x_box-2*wst_box;
y_box_inside=y_box-2*wst_box;

//bcb=[x_box/2,y_box/2,wst_box];

b_innards=[ 
  //holder for drone
  ["SC", [x_box_inside/2-170/2,y_box_inside/2-160/2,0], [170,160,13], 1, 7, "sides", "topbottom"], //holder for drone

  //batter compartments
  ["SC", [x_box/2-wst_box+48,85,0], [37,27,40], 1, 0, "none", "topbottom"],
  ["SC", [x_box/2-wst_box-37-48,85,0], [37,27,40], 1, 0, "none", "topbottom"],
  ["SC", [x_box/2-wst_box+48,85+27-1,0], [37,27,40], 1, 0, "none", "topbottom"],
  ["SC", [x_box/2-wst_box-37-48,85+27-1,0], [37,27,40], 1, 0, "none", "topbottom"],

  //left right boxes
  ["SC", [-1,85,0], [39,100,"max"], 1, 0, "none", "topbottom"],
  ["SC", [x_box-2*wst_box+1-39,85,0], [39,100,"max"], 1, 0, "none", "topbottom"],
  
  // main separating wall
  ["c",  [0,25,0], ["max",1,"max"]], 

  // magnet holders - note: this must respect lip_z which is defined inside LiddedBox
  ["MH", [5.7,5.7,0], z_box-lid_z_box+5, 45, 5], 
  ["MH", [x_box-5-5.7-2*wst_box,5.7,0], z_box-lid_z_box+5, 45, 5], 
  ["MH", [5.7,y_box-5-5.7-2*wst_box,0], z_box-lid_z_box+5, 45, 5], 
  ["MH", [x_box-5-5.7-2*wst_box,y_box-5-5.7-2*wst_box,0], z_box-lid_z_box+5, 45, 5], 
];


b_cutouts=[ 
  ["text", "front", [30,28], 0.5, "EB185", 8, "Helvetica:style=bold"], 
];

LiddedBox(x_box,y_box,z_box,lid_z_box,wst_box,"box",r_box,t_box,b_innards,b_cutouts);

translate([x_box+10,0,0]) {
  LiddedBox(x_box,y_box,z_box,lid_z_box,wst_box,"lid",r_box,t_box,b_innards,b_cutouts);
}
