// Global resolution
$fs = 0.1;
$fa = 5;

pins_deep = 4;
pins_wide = 4;

pin_dia = 3;
pin_length = 5;
pin_dist = 8;

module pins() {
  translate([0,0,-pin_length])
    for (width = [0:1:pins_wide-1])
      translate([pin_dist*width,0,0])
        for (depth = [0:1:pins_deep-1])
          translate([0,pin_dist*depth,0])
            cylinder(pin_length, pin_dia/2, pin_dia/2);
}

pins();
translate([-2,-2,0])
  cube([29,29,3]);