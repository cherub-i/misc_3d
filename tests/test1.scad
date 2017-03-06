use <../libs/function_helpers.scad>;
include <../libs/object_helpers.scad>;

$fa = 5;

x_box=100;
y_box=200;
z_box=150;
lid_z_box=50;
r_box=0;
t_box="all";
wst_box=3;

x_box_inside=x_box-2*wst_box;
y_box_inside=y_box-2*wst_box;



//bcb=[x_box/2,y_box/2,wst_box];

b_innards = [ ];
            

LiddedBox(x_box,y_box,z_box,lid_z_box,wst_box,"box",r_box,t_box,b_innards);

translate([x_box+10,0,0]) {
  LiddedBox(x_box,y_box,z_box,lid_z_box,wst_box,"lid",r_box,t_box,b_innards);
}
