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
// SCube(x,y,z,wst,r=0,rtype="all",otype="closed",center=true,innards)
//   creates a hollow cube which can have rounded edges
//   x, y, z = outer measures
//   wst = wall strength
//   r = radius of rounded edges, 0 deactivates rounding
//   rtype = [ "all" rounds all edges | "top" rounds top and vertical edges | "sides" rounds vertical edges ]
//   otype = [ "closed" closed hollowed cube | "top" cube open on top | "bottom" cube opened on botton | "topbottom" cube opened on top and botton ]
//   innards = array of things to create inside the cube, follows the following form:
//     [
//       type = [ "c" cube | "SC" SCube | "MH" MagHolder]
//       position = {x,y,z] // positioning is always done from front left bottom corner of the scube inside 
//       dimensions = [x,y,z] // dependent on type: usually support "max" to select the maximum possible length/height/depth possible 
//       further values: usually follow the paramters of the type involved
//     ]
// 
// RCube(x,y,z,r=0,type="all",center=true,s=10)
//   creates a solid cube which can have rounded edges
//   x, y, z = outer measures
//   r = radius of rounded edges, 0 deactivates rounding
//   type = [ "all" rounds all edges | "top" rounds top and vertical edges | "sides" rounds vertical edges ]
//   s = number of sides of the rounding
// 
// MagHolder(z,split_z,rotate=0,xy=5)
//   creates a post with room for 2 magnets (magnet size defined in function), the idea is, that the cube gets split a the exact height where the two magnest meet
//   z = height of the post
//   split_z = position where the magnest meet and the holder should get split
//   rotate = rotates the cube around the z-axis
//   xy = depth/width of the post
//   
//   
//
// PyramidenStumpf(Breite, Länge, Höhe, Verschmalerung) {
//   Pyramidenstumpf, die obere Fläche wird von jeder Kante aus um "Verschmalerung" verkleinert
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module LiddedBox(x,y,z,lid_z,wst,part,r,rtype,innards,cutouts) {
  //lid_z = height of lid
  //wst = wallstrength
  //part = "box" | "lid"
  part_allowed=[["box",1],["lid",2]];
  //r = radius for rounding of edges, 0 for no rounding
  //rtype = "all" rounds all edges | "top" rounds top and vertical edges | "sides" rounds only vertical edges
  rtype_allowed=[["all",1],["top",2],["sides",3]];

  box_z=z-lid_z;
  
  lip_z = 5; // height of lip
  lip_clearance = 0.1; // clearance between the box lip and lid lip
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

  if ( part=="box" ) {   
    difference() {
      //create the closed box
      SCube(x,y,z,wst,r,rtype,"closed",false,innards,cutouts);
      //cut down to box height + lip height
      translate([0,0,box_z+lip_z])
        cube([x,y,lid_z-lip_z]);
      //now trim down the lip
      translate([0,0,box_z])
        SCube(x,y,lip_z,wst-lip_wst,r,"sides","topbottom",false);
    }
  } else if ( part=="lid" ) {
    translate([x,0,z]) rotate([0,180,0])      
      difference() {
        //create the closed box
        SCube(x,y,z,wst,r,rtype,"closed",false,innards,cutouts);
        //cut down to lid height + lip height
        cube([x,y,box_z]);
        // now cut out the inside of the lip
        translate([lip_wst,lip_wst,box_z])
          RCube(x-2*(lip_wst),y-2*(lip_wst),lip_z,r_inner,"sides",false);
      }
  }
}

module SCube(x,y,z,wst,r=0,rtype="none",otype="closed",center=true,innards=[],cutouts=[]) {
  //wst = wallstrength
  //r = radius for rounding of edges, 0 for no rounding
  //rtype = [ "all" rounds all edges | "top" rounds top and vertical edges | "sides" rounds only vertical edges | "none" no rounding]
  rtype_allowed=[["all",1],["top",2],["sides",3],["none",4]];
  //otype = [ "closed" closed hollowed cube | "top" cube open on top | "bottom" cube opened on botton | "topbottom" cube opened on top and botton ]
  otype_allowed=[["closed",1],["top",2],["bottom",3],["topbottom",4]];
  //inards = complex TODO describe!
  innards_allowed = [["c",1],["SC",2],["MH",3]];
  //cutouts = cutouts in the hull - EXPERIMENTAL
  cutouts_allowed = [["text",1]];
  cutouts_pos_allowed = [["front",1], ["back",2], ["left",3], ["right",4], ["top",5], ["bottom",6]];
  
  assert_is_element_of(rtype,rtype_allowed,"unsupported rtype");
  assert_is_element_of(otype,otype_allowed,"unsupported otype");
  
  if ( r>0 ) {
    assert(rtype=="all"&&otype!="closed", "rtype=all can only be used with otype=closed");
    assert(((rtype=="top"&&otype=="top") || (rtype=="top"&&otype=="topbottom")), "rtype=top can only be used with otype=closed and otype=bottom");
    assert_greater(r,wst,"radius must be greater than wallstrength");
    assert(rtype=="none","rtype=none cannot be used with r>0");
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
  
  //uncenter the scube - note: everything is drawn centered first, no matter what parameter "center" says
  translate(xyz_uncenter) {
    difference() {
      RCube(x,y,z,r,rtype);
      translate([0,0,z_trans_actual])
        RCube(x-2*wst,y-2*wst,z_inner,r_inner,rtype);

      //generate cutouts
      if (cutouts) { 
        for ( in = cutouts ) {
          assert_is_element_of(in[0],cutouts_allowed,"unsupported cutout");
          assert_is_element_of(in[1],cutouts_pos_allowed,"unsupported cutout position");
          //echo("doing cutout: ",in);

          side=in[1];
          xy_pos=in[2];
          depth=in[3];
          text_content=in[4];
          text_size=in[5];
          text_style=in[6];

          //calculate where to rotate and translate in order to put on the respective side
          cutout_pos = 
            side=="front"  ? [[-x/2 + xy_pos[0], -y/2 + depth    , -z/2 + xy_pos[1]], [90,  0, 0  ]] : 
            side=="back"   ? [[ x/2 - xy_pos[0],  y/2 - depth    , -z/2 + xy_pos[1]], [90,  0, 180]] : 
            side=="left"   ? [[-x/2 + depth    ,  y/2 - xy_pos[0], -z/2 + xy_pos[1]], [90,  0, 270]] : 
            side=="right"  ? [[ x/2 - depth    , -y/2 + xy_pos[0], -z/2 + xy_pos[1]], [90,  0, 90 ]] : 
            side=="top"    ? [[-x/2 + xy_pos[0], -y/2 + xy_pos[1],  z/2 - depth]    , [0,   0, 0  ]] : 
            side=="bottom" ? [[-x/2 + xy_pos[0],  y/2 - xy_pos[1], -z/2 + depth]    , [180, 0, 0  ]] : 
            [[0,0,0], [0,0,0]];
          
          if ( in[0]=="text" ) {
            translate(cutout_pos[0]) rotate(cutout_pos[1])
              linear_extrude(depth) text(text_content, text_size, font = text_style);
          }
        }
      }
    }
    
    //generate innards
    if (innards) { 
      intersection() {
        translate([0,0,z_trans_actual])
          RCube(x-2*wst,y-2*wst,z_inner,r_inner,rtype);
        for ( in = innards ) {
          assert_is_element_of(in[0],innards_allowed,"unsupported innard");
          //echo("doing innard: ",in);

          t_xyz=in[1];

          if ( in[0]=="c" || in[0]=="SC" ) {            
            //calculate dimensions
            xyz=in[2];

            x_in = xyz[0] == "max" ? x : xyz[0];
            y_in = xyz[1] == "max" ? y : xyz[1];
            z_in = xyz[2] == "max" ? z : xyz[2];
            
            xyz_in=[x_in,y_in,z_in];
            
            //calculate translation
            t_xyz_in = [ -x/2+wst + x_in/2 + t_xyz[0], -y/2+wst + y_in/2 + t_xyz[1], -z/2+wst + z_in/2 + t_xyz[2] ];
            
            if ( in[0] == "c" ) {
              translate(t_xyz_in)
                cube(xyz_in,true);
            } else if ( in[0] == "SC" ) {
              translate(t_xyz_in)
                SCube(xyz_in[0],xyz_in[1],xyz_in[2],in[3], in[4], in[5], in[6], true);
            }
          } else if ( in[0] == "MH" ) {
            mh_z=z; //mag holder always uses full height of box
            mh_split_z=in[2];
            mh_rotate=in[3];
            mh_xy=in[4];
            
            //calculate translation
            t_xyz_in = [ -x/2+wst + mh_xy/2 + t_xyz[0], -y/2+wst + mh_xy/2 + t_xyz[1], 0 ];
            
            translate(t_xyz_in)
              MagHolder(mh_z,mh_split_z,mh_rotate,mh_xy);
            
          }
        }
      }
    }
  }
}

module RCube(x,y,z,r=0,type="all",center=true,s=10) {
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
    } else if (type=="sides") {
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
    } else if (type=="top") {
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

module cross_box(x,y,z,r) {
	cube(size=[x-2*r,y-2*r,z],center=true);
	cube(size=[x-2*r,y,z-2*r],center=true);
	cube(size=[x,y-2*r,z-2*r],center=true);
}

module MagHolder(z,split_z,rotate=0,xy=5) {
  mag_size=4;
  min_wst=0.5;
  assert_greater_or_equal(xy,mag_size+2*min_wst,"MagHolder: xy must be greater than mag_size + 2*min_wst");
  
  rotate([0,0,rotate]) difference() {
    cube([xy,xy,z],true);
    translate([0,0,-z/2+split_z])
      cube([mag_size,mag_size,2*mag_size],true);
  }
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