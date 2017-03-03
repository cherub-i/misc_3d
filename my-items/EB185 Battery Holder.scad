// batteryholder for eb185

bat_w = 36;
bat_l = 72;
holder_str = 2.5;
holder_w = 4;

plate_str = 1.5;
holder_h = 10;
slit_l = 23.6;

plate_w = bat_w + 2*holder_str;
plate_l = bat_l + 2*holder_str;

module holderA (){
difference() {
  cube([bat_l + 2*holder_str, bat_w + 2*holder_str, 10]);
  translate([holder_str,holder_str,holder_str])
    cube([bat_l, bat_w, 10]);
}
}

module test() {
mid_cube_len = (bat_l/4 - 2*holder_w) * 2;
  translate([bat_l/2 - mid_cube_len/2, (bat_w - holder_w)/2 - 20, 0])
    cube([mid_cube_len, 20, 20]);
  translate([bat_l/2 - mid_cube_len/2, (bat_w + holder_w) - 20, 0])
    cube([mid_cube_len, 20, 20]);
}


module holder() {

  union() {
    cube([plate_w, slit_l, plate_str]);
    cube([holder_str, slit_l, holder_h]);
    translate([plate_w-holder_str,0,0])
      cube([holder_str, slit_l, holder_h]);
  }
  translate([plate_w/2-20/2,-12,0])
    union() {
      cube([20, plate_l, plate_str]);
      cube([20, holder_str, holder_h]);
      translate([0,plate_l-holder_str,0])
        cube([20, holder_str, holder_h]);
    }
}
  
module feet() {
  translate([(41-(28.2+2*3))/2, 0, -2]) 
    difference () {
      cube([28.2+2*3, 23.6, 2]);
      translate([3,0,0])
        cube([28.2, 23.6, 2]);
    }
}

//holder();
difference() {
  cube([plate_w, slit_l, plate_str]);
  translate([plate_w/2-20/2, 0, plate_str/2])
    cube([20, slit_l, plate_str/2]);
}
feet();