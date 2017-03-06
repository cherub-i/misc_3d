use <../libs/function_helpers.scad>;
include <../libs/object_helpers.scad>;

$fa=5;
$fn=60;

//qx95 box
x_box=150;
y_box=200;
z_box=70;
lid_z_box=27;
r_box=[5,[25,0,25,25],0];
wst_box=1.8;

x_box_inside=x_box-2*wst_box;
y_box_inside=y_box-2*wst_box;

//bcb=[x_box/2,y_box/2,wst_box];

b_innards=[ 
  //holder for drone
  ["SC2", [x_box_inside/2-88/2,y_box_inside/2-88/2+(y_box_inside-x_box_inside-1.5)/2,0], [88,88,15], 1, [0,[7,7,7,7],0], "topbottom"],
  
  //main separating wall
  ["c",  [0,y_box_inside-x_box_inside-1.5,0], ["max",1.5,"max"]], 

  //battery compartments
  ["SC2", [0*11-1,22,0], [12,28,40], 1, [0,[0,0,0,0],0], "topbottom"], 
  ["SC2", [1*11-1,22,0], [12,28,40], 1, [0,[0,0,0,0],0], "topbottom"], 
  ["SC2", [2*11-1,22,0], [12,28,40], 1, [0,[0,0,0,0],0], "topbottom"], 
  ["SC2", [3*11-1,22,0], [12,28,40], 1, [0,[0,0,0,0],0], "topbottom"], 
  ["SC2", [4*11-1,22,0], [12,28,40], 1, [0,[0,0,0,0],0], "topbottom"], 
  ["SC2", [5*11-1,22,0], [12,28,40], 1, [0,[0,0,0,0],0], "topbottom"], 

  // additional separating wall
  ["c", [6*11-1,0,0], [1,50,"max"]], 

  // magnet holders - note: this must respect lip_z which is defined inside LiddedBox
//  ["MH", [5.7,5.7,0], z_box-lid_z_box+5, 45, 5],  // for rounding 25
  ["MH", [-0.5,-0.5,0], z_box-lid_z_box+5, 0, 5], 
  ["MH", [x_box-5-5.7-2*wst_box,5.7,0], z_box-lid_z_box+5, 45, 5], 
  ["MH", [5.7,y_box-5-5.7-2*wst_box,0], z_box-lid_z_box+5, 45, 5], 
  ["MH", [x_box-5-5.7-2*wst_box,y_box-5-5.7-2*wst_box,0], z_box-lid_z_box+5, 45, 5], 
];


b_cutouts=[ 
  ["text", "front", [5,5], 0.5, "QX95", 8, "Helvetica:style=bold"], 
  ["text", "left", [158,9], 0.5, "if found, return to:", 3, "Helvetica:style=bold"], 
["text", "left", [134,5], 0.5, "drones@bastianbaumeister.de", 3, "Helvetica:style=bold"], 
];


LiddedBox2([x_box,y_box,z_box],lid_z_box,wst_box,"box",r_box,b_innards,b_cutouts);

translate([x_box+10,0,0]) {
  LiddedBox2([x_box,y_box,z_box],lid_z_box,wst_box,"lid",r_box,b_innards,b_cutouts);
}



/*
//add posts for securing the drone
translate([bcb[0]-5,bcb[1]-10,bcb[2]])
  tube_grid(20,2,2,20,10);
*/


/*
module tube_grid(z,row,cols,row_space,col_space) {
  for (x = [0 : col_space : (cols-1) * col_space] ) {
    for (y = [0 : row_space : (row-1) * row_space] ) {
      translate([x,y,0]) tube(z);
    }
  }
}

module tube(z,di=2.2,do=4) {
// Schrauben: 2.2mm Schaft, 2.5mm Gewunde, 5.3mm Kopf, Schaft-Länge 8mm
  difference() {
    cylinder(h=z,d=do);
    cylinder_outer(z,di/2);
  }
}

module cylinder_outer(height,radius,fn){
  fudge = 1/cos(180/fn);
  cylinder(h=height,r=radius*fudge,$fn=fn);
}
*/