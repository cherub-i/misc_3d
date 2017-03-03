/*
Messwerte

Achse Durchmesser: 6,00mm
Achse Abflachung: 1,54mm
Auflage Achse Duchmesser: 12mm
Achse Länge innerhalb Maschine: 2,35
Achse Länge außerhalb Maschine: 4,78

Knopf Länge: 14
Knopf Durchmesser: 40
Knopf Inset: 37
Knopf Inset Tiefe: 1,5

Durchmesser Loch in Verkleidung: 25,3mm
*/

// Global resolution
$fs = 0.1;  // Don't generate smaller facets than 0.1 mm
$fa = 5;    // Don't generate larger angles than 5 degrees

knob_dia = 40;
knob_len = 14;
knob_thick = 2.5;
knob_inset_dia = 37;
knob_inset_len = 1.5;
pin_dia = 13;
pin_len = 2.35;
achsle_dia = 6.5;
achsle_flat = 1.5;
achsle_len = 8;

padding = 0.5;

//difference() {
//    cylinder(pin_len, pin_dia / 2, pin_dia / 2, false);
//}

module achsle() {
  difference () {
    cylinder(achsle_len, achsle_dia / 2, achsle_dia / 2);
    translate([achsle_dia-achsle_flat ,0  , achsle_len/2]) 
      cube([achsle_dia, achsle_dia, achsle_len], true);
  }
}

module pin() {
  difference() {
    cylinder(pin_len + knob_len, pin_dia / 2, pin_dia / 2);
    achsle();
  }
}

module knob() {
  union() {
    difference() {
      cylinder(knob_len, knob_dia / 2, knob_dia / 2);
      //the big inside cavity
      cylinder(knob_len - knob_thick, knob_dia / 2 - knob_thick, knob_dia / 2 - knob_thick);
      //a nice "riffelung" on the outside
      for (i = [0:4:360])
        rotate([0, 0, i])
          translate([knob_dia / 2, 0, 3])
            cylinder(knob_len - 3, 0.5, 0.5);
    }
    //inner support structure for the pin
    for (i = [0:90:360])
      rotate([0, 0, i]) 
        translate([-knob_thick/4, pin_dia / 2, +2]) 
          cube([knob_thick/2, knob_dia/2 - pin_dia/2 - knob_thick , knob_len-2]);
  }
}

//knob();
//pin();
//achsle();

intersection() {
  sphere (25);
difference() {
  union() {
    translate([0, 0, pin_len]) knob();
    pin();
  }
  //an inset on top, to put in a nice inlay
  translate([0, 0, pin_len+knob_len-knob_inset_len+padding]) cylinder(knob_inset_len+padding, knob_inset_dia / 2, knob_inset_dia / 2 );
}
}

//TODO
//Riffelung am Griff
//Verstärkung für Pin