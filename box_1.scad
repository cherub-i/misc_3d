use <libs/function_helpers.scad>;
include <libs/object_helpers.scad>;

$fa = 5;

//qx95 box
x_box=150;
y_box=200;
z_box=65;
lid_z_box=30;
r_box=5;
wst_box=3;

bcb=[x_box/2,y_box/2,wst_box];


LiddedBox(x_box,y_box,z_box,lid_z_box,wst_box,"box",r_box,"top");

//add support for drone
translate([bcb[0],bcb[1],bcb[2]+13/2])
  SCube(88,88,13,1,7,"sides","topbottom",true);

//add posts for securing the drone
translate([bcb[0]-5,bcb[1]-10,bcb[2]])
  tube_grid(20,2,2,20,10);



translate([x_box+10,0,0]) {
  LiddedBox(x_box,y_box,z_box,lid_z_box,wst_box,"lid",r_box,"top");
  //translate([bcb[0]-2*15,bcb[1]-2*15,bcb[2]])
    //tube_grid(10,5,5,15,15);

}

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

/*translate([0,0,0]) {
  difference() {
    cube([10,1,10]);
    translate([5,1,6]) rotate([90,0,0])
      linear_extrude(1) text("J", size=5, font="Liberation Sans", halign="center");
  }  
 }*/
 
 
