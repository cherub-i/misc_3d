////////////////////////////////////////////////////////////////////////////////////////////////////
// copyright by Bastian Baumeister | openscad@bastianbaumeister.de 
// object helpers
////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// LiddedBox(x, y, z, lid_z,wst,part,r,rtype)
//   creates a box with lid which can have rounded corners according to the type defined
//   x, y, z = outer measures
//   lid_z = height of lid (inside will be higher because of the lid-lip
//   part = [ "box" the lower part | "lid" the lid ]
//   r = radius of rounded edges, 0 deactivates rounding (default = 0)
//   rtype = [ "all" rounds all edges | "top" rounds top and vertical edges | "sides" rounds vertical edges ]
// 
// SCube(x,y,z,wst,r=0,rtype="all",otype="closed",center=true)
//   creates a hollow cube which can have rounded edges
//   x, y, z = outer measures
//   wst = wall strength
//   r = radius of rounded edges, 0 deactivates rounding
//   rtype = [ "all" rounds all edges | "top" rounds top and vertical edges | "sides" rounds vertical edges ]
//   otype = [ "closed" closed hollowed cube | "top" cube open on top | "bottom" cube opened on botton | "topbottom" cube opened on top and botton ]
// 
// RCube(x,y,z,r=0,type="all",center=true,s=10)
//   creates a solid cube which can have rounded edges
//   x, y, z = outer measures
//   r = radius of rounded edges, 0 deactivates rounding
//   type = [ "all" rounds all edges | "top" rounds top and vertical edges | "sides" rounds vertical edges ]
//   s = number of sides of the rounding
// 
// PyramidenStumpf(Breite, Länge, Höhe, Verschmalerung) {
//   Pyramidenstumpf, die obere Fläche wird von jeder Kante aus um "Verschmalerung" verkleinert
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module LiddedBox(x,y,z,lid_z,wst,part,r,rtype,innards) {
  //lid_z = height of lid
  //wst = wallstrength
  //part = "box" | "lid"
  part_allowed=[["box",1],["lid",2]];
  //r = radius for rounding of edges, 0 for no rounding
  //rtype = "all" rounds all edges | "top" rounds top and vertical edges | "sides" rounds only vertical edges
  rtype_allowed=[["all",1],["top",2],["sides",3]];

  box_z=z-lid_z;
  
  lip_z = 5; // height of lip
  lip_clearance = 0.2; // clearance between the box and lid lips
  lip_wst=wst/2-lip_clearance/2; // resulting lip wallstrength

  assert_is_element_of(part,part_allowed,"unsupported part");
  assert_is_element_of(rtype,rtype_allowed,"unsupported rtype");
  
  if (r>0) {
    assert_greater(r,wst,"radius must be greater than wallstrength");
    if (rtype=="top")
      assert_greater_or_equal(lid_z,r,"for a rounded top, lid_z must be greater than r");
    if (rtype=="all")
      assert_greater_or_equal(min(box_z,lid_z),r,"for a fully rounded box, box_z and lid_z must be greater than r");
  }
  r_inner = r>0 ? r-(wst-lip_wst) : 0;
  
    
  if (part=="box") {   
    difference() {
      //create the closed box
      SCube(x,y,z,wst,r,rtype,"closed",false,innards);
      //cut down to box height + lip height
      translate([0,0,box_z+lip_z])
        cube([x,y,lid_z-lip_z]);
      //now trim down the lip
      translate([0,0,box_z])
        SCube(x,y,lip_z,wst-lip_wst,r,"sides","topbottom",false);
    }
  } else {  // type = "lid"
    translate([0,y,z]) rotate([180,0,0])      
      difference() {
        //create the closed box
        SCube(x,y,z,wst,r,rtype,"closed",false,innards);
        //cut down to lid height + lip height
        cube([x,y,box_z-lip_z]);
        // now cut out the inside of the lip
        translate([wst-lip_wst,wst-lip_wst,box_z-lip_z])
          RCube(x-2*(wst-lip_wst),y-2*(wst-lip_wst),lip_z,r_inner,"sides",false);
      }
  }
}

module SCube(x,y,z,wst,r=0,rtype="all",otype="closed",center=true,innards=[]) {
  //wst = wallstrength
  //r = radius for rounding of edges, 0 for no rounding
  //rtype = [ "all" rounds all edges | "top" rounds top and vertical edges | "sides" rounds only vertical edges ]
  rtype_allowed=[["all",1],["top",2],["sides",3]];
  //otype = [ "closed" closed hollowed cube | "top" cube open on top | "bottom" cube opened on botton | "topbottom" cube opened on top and botton ]
  otype_allowed=[["closed",1],["top",2],["bottom",3],["topbottom",4]];
  //inards = complex TODO describe!
  innards_allowed = [["c",1],["v",2]];
  
  assert_is_element_of(rtype,rtype_allowed,"unsupported rtype");
  assert_is_element_of(otype,otype_allowed,"unsupported otype");
  
  if (r>0) {
    assert(rtype=="all"&&otype!="closed", "rtype=all can only be used with otype=closed");
    assert(((rtype=="top"&&otype=="top") || (rtype=="top"&&otype=="topbottom")), "rtype=top can only be used with otype=closed and otype=bottom");
    assert_greater(r,wst,"radius must be greater than wallstrength");
  }
  
  //radius for inner rounding must be reduced by wst if rounding is active
  r_inner = r>0 ? r-wst : r;

  //inside z and z translation has to be adjusted according to opening type
  z_inner = otype=="top" || otype=="bottom" ? z-wst : 
      otype=="closed" ? z-2*wst : z;
    //echo("z=", z," z_actual=", z_inner);
  z_trans_actual = otype=="top" ? wst/2 : 
      otype=="bottom" ? -wst/2 : 0;
  
  xyz_uncenter = (center) ? [0,0,0] : [x/2,y/2,z/2];
  
  translate(xyz_uncenter) {
    difference() {
      RCube(x,y,z,r,rtype);
      translate([0,0,z_trans_actual])
        RCube(x-2*wst,y-2*wst,z_inner,r_inner,rtype);
    }
    if (innards)    
      intersection() {
        translate([0,0,z_trans_actual])
          RCube(x-2*wst,y-2*wst,z_inner,r_inner,rtype);
        for ( in = innards ) {
          assert_is_element_of(in[0],innards_allowed,"unsupported innard");
          echo(in);
          x_in = in[1][0] == "max" ? x : in[1][0];
          y_in = in[1][1] == "max" ? y : in[1][1];
          z_in = in[1][2] == "max" ? z : in[1][2];
          if (in[0] == "c")
            cube([x_in,y_in,z_in],true);
        }
    }
  }
}

module RCube(x,y,z,r=0,type="all",center=true,s=3) {
  //r = radius of rounded edges, 0 deactivates rounding
  //type = [ "all" rounds all edges | "top" rounds top and vertical edges | "sides" rounds vertical edges ]
  //s = number of sides of the rounding

  xyz_uncenter = (center) ? [0,0,0] : [x/2,y/2,z/2];

  if (r==0) {
    cube([x,y,z],center);
  } else { //r>0
    //assert_is_element_of(type, ["all","top","sides"], "message");
    if (type=="all") {
      assert_greater_or_equal(x/2,r,"x/2 > r");
      assert_greater_or_equal(y/2,r,"y/2 > r");
      assert_greater_or_equal(z/2,r,"z/2 > r");
      
      translate(xyz_uncenter) {
        hull() {
          cross_box(x,y,z,r);
          translate([  x/2-r ,  y/2-r ,  z/2-r ]) sphere(r, $fn=4*s);
          translate([  x/2-r ,-(y/2-r),  z/2-r ]) sphere(r, $fn=4*s);
          translate([-(x/2-r),-(y/2-r),  z/2-r ]) sphere(r, $fn=4*s);
          translate([-(x/2-r),  y/2-r ,  z/2-r ]) sphere(r, $fn=4*s);

          translate([  x/2-r ,  y/2-r ,-(z/2-r)]) sphere(r, $fn=4*s);
          translate([  x/2-r ,-(y/2-r),-(z/2-r)]) sphere(r, $fn=4*s);
          translate([-(x/2-r),-(y/2-r),-(z/2-r)]) sphere(r, $fn=4*s);
          translate([-(x/2-r),  y/2-r ,-(z/2-r)]) sphere(r, $fn=4*s);
        }
      }
    }
    if (type=="sides") {
      assert_greater_or_equal(x/2,r,"x/2 > r");
      assert_greater_or_equal(y/2,r,"y/2 > r");
      
      translate(xyz_uncenter) {
        hull() {
          cross_box(x,y,z,r);

          translate([  x/2 -r ,  y/2 -r ,0]) cylinder(z,r,r,true, $fn=4*s);
          translate([  x/2 -r ,-(y/2 -r),0]) cylinder(z,r,r,true, $fn=4*s);
          translate([-(x/2 -r),-(y/2 -r),0]) cylinder(z,r,r,true, $fn=4*s);
          translate([-(x/2 -r),  y/2 -r ,0]) cylinder(z,r,r,true, $fn=4*s);
        }
      }
    }
    if (type=="top") {
      assert_greater_or_equal(x/2,r,"x/2 > r");
      assert_greater_or_equal(y/2,r,"y/2 > r");
      assert_greater_or_equal(z/2,r,"z/2 > r");
      
      translate(xyz_uncenter) {
        hull() {
          cross_box(x,y,z,r);
          translate([  x/2-r ,  y/2-r ,  z/2-r ]) sphere(r, $fn=4*s);
          translate([  x/2-r ,-(y/2-r),  z/2-r ]) sphere(r, $fn=4*s);
          translate([-(x/2-r),-(y/2-r),  z/2-r ]) sphere(r, $fn=4*s);
          translate([-(x/2-r),  y/2-r ,  z/2-r ]) sphere(r, $fn=4*s);

          translate([  x/2-r ,  y/2-r ,-(z/2-r/2)]) cylinder(r,r,r,true, $fn=4*s);
          translate([  x/2-r ,-(y/2-r),-(z/2-r/2)]) cylinder(r,r,r,true, $fn=4*s);
          translate([-(x/2-r),-(y/2-r),-(z/2-r/2)]) cylinder(r,r,r,true, $fn=4*s);
          translate([-(x/2-r),  y/2-r ,-(z/2-r/2)]) cylinder(r,r,r,true, $fn=4*s);
        }
      }
    } 
  }
}

module cross_box(x,y,z,r){
	cube(size=[x-2*r,y-2*r,z],center=true);
	cube(size=[x-2*r,y,z-2*r],center=true);
	cube(size=[x,y-2*r,z-2*r],center=true);
}

module PyramidenStumpf(Breite, Laenge, Hoehe, Verschmalerung) {
  //zentriert gezeichneter Pyramidenstumpf, die obere Fläche wird 
  //von jeder Kante aus um das Maß "Verschmalerung" verkleinert
  polyhedron(
    points = [ [Breite/2,Laenge/2,0],   //0
               [Breite/2,-Laenge/2,0],  //1
               [-Breite/2,-Laenge/2,0], //2
               [-Breite/2,Laenge/2,0],  //3
               
               [Breite/2-Verschmalerung,Laenge/2-Verschmalerung,Hoehe],   //4
               [Breite/2-Verschmalerung,-Laenge/2+Verschmalerung,Hoehe],  //5
               [-Breite/2+Verschmalerung,-Laenge/2+Verschmalerung,Hoehe], //6
               [-Breite/2+Verschmalerung,Laenge/2-Verschmalerung,Hoehe]   //7
    ],
    faces = [ [3,2,1,0], //bottom
              [4,5,6,7], //top
              [5,1,2,6], //front
              [7,3,0,4], //back
              [6,2,3,7], //left
              [4,0,1,5]  //right
            ]
  );  
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// DEPRECATED
////////////////////////////////////////////////////////////////////////////////////////////////////

module Kiste(b,t,h,hd,st,typ,r) {
  //DEPRECATED
  //b = Breite, außen
  //t = Tiefe, außen
  //h = Höhe, außen
  //hd = Höhe des Deckels
  //st = Wandstärke (demnach: Innenmaße = Außenmaße - 2 x Wandstärke) 
  //typ = "box" oder "deckel"  
  
  hb = h-hd;
  //hb = Höhe der Box
  
  ue = 5;
  //Überlappung von Box und Deckel, addiert sich zum Box-Teil

  assert_greater(h/2,hd,"halbe (Gesamt)Höhe > Höhe des Deckels (hd)!");
  if (r>0)
    assert_greater_or_equal(hd-ue,r,"Höhe des Deckels (hd) - Überlappung (ue) >= Radius der Rundung (r)!");
  
  if (typ=="box") {
    union() {
      difference() {
        GeschlosseneKiste(b,t,h,st,false,r);
        translate([0,0,hb])
          cube([b,t,hd]);
      }
      translate([st/2,st/2,hb])
        OffeneKiste(b-st,t-st,ue,st/2,false,r);
    }
  } else {  // typ = "deckel", etc.
    difference() {
      GeschlosseneKiste(b,t,h,st,false,r);
      cube([b,t,hb+ue]);
    }
    translate([0,0,hb])
      OffeneKiste(b,t,ue,st/2,false,r);
  }
}

module dep_GeschlosseneKiste(b,t,h,st,centered,r) {
  //b = Breite, außen
  //t = Tiefe, außen
  //h = Höhe, außen
  //st = Wandstärke (demnach: Innenmaße = Außenmaße - 2 x Wandstärke)
  //r = Rundung der senkrechten Kanten, 0 schaltet Rundung aus

  if (centered) {
    difference() {
      RCube(b,t,h,r,"sides");
      RCube(b-2*st,t-2*st,h-2*st,r-st,"all");
    }
  } else {
    translate([b/2,t/2,h/2]) {
      difference() {
        RCube(b,t,h,r,"sides");
        RCube(b-2*st,t-2*st,h-2*st,r-st,"all");
      }
    }
  }
}

module dep_OffeneKiste(b,t,h,st,centered,r) {
  //b = Breite, außen
  //t = Tiefe, außen
  //h = Höhe, außen
  //st = Wandstärke (demnach: Innenmaße = Außenmaße - 2 x Wandstärke)
  //r = Rundung der senkrechten Kanten, 0 schaltet Rundung aus

  if (centered) {
    difference() {
      RCube(b,t,h,r,"sides");
      RCube(b-2*st,t-2*st,h,r-st,"sides");
    }
  } else {
    translate([b/2,t/2,h/2]) {
      difference() {
        RCube(b,t,h,r,"sides");
        RCube(b-2*st,t-2*st,h,r-st,"sides");
      }
    }
  }
}

module dep_CubeGerundetFlach(b,t,h,r) {
  translate([-(b/2-r),-(t/2-r),0]) {
    minkowski() {
      cube([b-r*2,t-r*2,h/2],true);
      translate([b/2-r,t/2-r,0])
        cylinder(h/2,r,r,true);
    }
  }  
}

module dep_CubeGerundet(b,t,h,r) {
  translate([-(b/2-r),-(t/2-r),]) {
    minkowski() {
      cube([b-r*2,t-r*2,h-2*r],true);
      translate([b/2-r,t/2-r,0])
        sphere(r);
    }
  }  
}