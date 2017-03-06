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
// SCube(x,y,z,wst,r=0,rtype="all",otype="closed",center=true,innards,cutouts)
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

module LiddedBox2(size,lid_z,wst,part,rounding,innards,cutouts) {
  // creates either a lid or a box, the box can congtain inside elements and cutouts on the ousides
  //   size = [x, y, z] /gives outer dimensions
  //   lid_z = height of lid
  //   wst = wallstrength
  //   part = "box" | "lid"
  part_allowed=[["box",1],["lid",2]];
  //   rounding = [top rounding, [corner 1 rounding, c2r, c3r, c4r] bottom_rounding] /gives the radius for rounding the edges: all top or all bottom edges or individual 
  //   inards = an array containg objects which can be placed inside the box
  //     pos(x,y,z] is calculated from the front left inside corner 
  //     size[x,y,z] supports "max", which results in the object taking the full extend along that axis
  //     ["c", pos[xyz], size[xyz], wst]
  //     ["SC2", pos[xyz], size[xyz], wst, r[t,[c1,c2,c3,c4],b], otype]
  //     ["MH", pos[xyz], split_z, rot_z, size_xy]
  //     ["SC", pos[xyz], size[xyz], wst, r, rtype, otype]
  //   cutouts = cutouts in the hull - EXPERIMENTAL
  //     ["text", "front", [30,28], 0.5, "QX95", 8, "Helvetica:style=bold"], 
  //     ["rect", "bottom", [plug_x,plug_y], wst_cap, [28,20], true], //plug
  //     ["circle", "bottom", [plug_x-20,plug_y], wst_cap, 2, true], //plug screw 
  x=size[0];
  y=size[1];
  z=size[2];

  box_z=z-lid_z;
    
  lip_z = 5; // height of lip
  lip_clearance = 0.1; // clearance between the box lip and lid lip
  lip_wst=wst/2-lip_clearance/2; // resulting lip wallstrength

  assert_is_element_of(part,part_allowed,"unsupported part");
  
  rmid_inner=[ rounding[1][0]-wst >= 0 ? rounding[1][0]-(wst-lip_wst) : 0,
               rounding[1][1]-wst >= 0 ? rounding[1][1]-(wst-lip_wst) : 0,
               rounding[1][2]-wst >= 0 ? rounding[1][2]-(wst-lip_wst) : 0,
               rounding[1][3]-wst >= 0 ? rounding[1][3]-(wst-lip_wst) : 0  ];

  if ( part=="box" ) {   
    difference() {
      //create the closed box
      SCube2(size,wst,rounding,"closed",false,innards,cutouts);
      //cut down to box height + lip height
      translate([0,0,box_z+lip_z])
        cube([x,y,lid_z-lip_z]);
      //now trim down the lip
      translate([0,0,box_z])
        SCube2([x,y,lip_z],wst-lip_wst,[0,rounding[1],0],"topbottom",false);
    }
  } else if ( part=="lid" ) {
    translate([x,0,z]) rotate([0,180,0])      
      difference() {
        //create the closed box
        SCube2(size,wst,rounding,"closed",false,innards,cutouts);
        //cut down to lid height + lip height
        cube([x,y,box_z]);
        // now cut out the inside of the lip
        translate([lip_wst,lip_wst,box_z])
          RCube2([x-2*(lip_wst),y-2*(lip_wst),lip_z],[0,rmid_inner,0],false);
      }
  }
}

module SCube2(size,wst,rounding,otype="closed",center=true,innards=[],cutouts=[]) {
  // creates a hollow box
  //   size = [x, y, z] /gives outer dimensions
  //   wst = wallstrength
  //   rounding = [top rounding, [corner 1 rounding, c2r, c3r, c4r] bottom_rounding] /gives the radius for rounding the edges: all top or all bottom edges or individual 
  //   otype = [ "closed" closed hollowed cube | "top" / "bottom" / "topbottom" cube open on respective side(s)
  otype_allowed=[["closed",1],["top",2],["bottom",3],["topbottom",4]];
  //   inards = an array containg objects which can be placed inside the box
  //     pos(x,y,z] is calculated from the front left inside corner 
  //     size[x,y,z] supports "max", which results in the object taking the full extend along that axis
  //     ["c", pos[xyz], size[xyz], wst]
  //     ["SC2", pos[xyz], size[xyz], wst, r[t,[c1,c2,c3,c4],b], otype]
  //     ["MH", pos[xyz], split_z, rot_z, size_xy]
  //     ["SC", pos[xyz], size[xyz], wst, r, rtype, otype]
  innards_allowed = [["c",1],["SC2",2],["MH",3],["SC",4]];
  //   cutouts = cutouts in the hull - EXPERIMENTAL
  cutouts_allowed = [["text",1], ["rect",2], ["circle",3]];
  cutouts_pos_allowed = [["front",1], ["back",2], ["left",3], ["right",4], ["top",5], ["bottom",6]];

  //echo("running SCube2(size,wst,rounding,otype,center,innards,cutouts)", "size:",size, "wst:",wst , "rounding:",rounding, "otype:",otype, "center:",center, "innards:",innards, "cutouts:",cutouts);
  
  assert_is_element_of(otype,otype_allowed,"unsupported otype");

  x=size[0];
  y=size[1];
  z=size[2];
  
  if ( rounding[0]+rounding[2] + rounding[1][0]+rounding[1][1]+rounding[1][2]+rounding[1][3] > 0 ) {
    //roundings involved
    if ( rounding[0]+rounding[2] > 0 ) {
      assert(otype=="topbottom", "rtype=closed can only be used with no rounding at top or bottom");
      assert((otype=="top" && rounding[0]>0), "rtype=top can only be used with no rounding at top");
      assert((otype=="bottom" && rounding[2]>0), "rtype=bottom can only be used with no rounding at bottom");
    }
  }
  
  //radius for inner rounding must be reduced by wst if rounding is active
  rounding_inner = [ rounding[0]-wst >= 0 ? rounding[0]-wst : 0,
                     [ rounding[1][0]-wst >= 0 ? rounding[1][0]-wst : 0,
                       rounding[1][1]-wst >= 0 ? rounding[1][1]-wst : 0,
                       rounding[1][2]-wst >= 0 ? rounding[1][2]-wst : 0,
                       rounding[1][3]-wst >= 0 ? rounding[1][3]-wst : 0  ],
                     rounding[2]-wst >= 0 ? rounding[2]-wst : 0 ];

  //inside z and z translation has to be adjusted according to opening type
  z_inner = otype=="top" || otype=="bottom" ? z-wst : 
      otype=="closed" ? z-2*wst : z;
    //echo("z=",z," z_actual=",z_inner);
  z_trans_actual = otype=="top" ? wst/2 : 
      otype=="bottom" ? -wst/2 : 0;
  
  xyz_uncenter = (center) ? [0,0,0] : [x/2,y/2,z/2];
  
  //uncenter the scube - note: everything is drawn centered first, no matter what parameter "center" says
  translate(xyz_uncenter) {
    difference() {
      RCube2(size,rounding);
      translate([0,0,z_trans_actual])
          RCube2([x-2*wst,y-2*wst,z_inner],rounding_inner);

      //generate cutouts
      if (cutouts) { 
        for ( in = cutouts ) {
          assert_is_element_of(in[0],cutouts_allowed,"unsupported cutout");
          assert_is_element_of(in[1],cutouts_pos_allowed,"unsupported cutout position");
          //echo("doing cutout: ",in);

          side=in[1];
          xy_pos=in[2];
          depth=in[3];
          
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
            text_content=in[4];
            text_size=in[5];
            text_style=in[6];
            
            translate(cutout_pos[0]) rotate(cutout_pos[1])
              linear_extrude(depth) text(text_content, text_size, font = text_style);
          } else if ( in[0]=="rect" ) {
            square_xy=in[4];
            square_center=in[5];
            
            translate(cutout_pos[0]) rotate(cutout_pos[1])
              linear_extrude(depth) square(square_xy, square_center);
          } else if ( in[0]=="circle" ) {
            circle_d=in[4];
            circle_center=in[5];
            
            circle_translate = circle_center ? [0,0,0] : [circle_d/2, circle_d/2, 0];
            
            translate(cutout_pos[0]) rotate(cutout_pos[1])
              linear_extrude(depth) translate(circle_translate) circle(d=circle_d);
          }
        }
      }
    }
    
    //generate innards
    if (innards) { 
      intersection() {
        translate([0,0,z_trans_actual])
          RCube2([x-2*wst,y-2*wst,z_inner],rounding_inner);
        for ( in = innards ) {
          assert_is_element_of(in[0],innards_allowed,"unsupported innard");
          //echo("doing innard: ",in);

          t_xyz=in[1];

          if ( in[0]=="SC" ) {            
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
          } else if ( in[0]=="c" || in[0]=="SC2" ) {            
            //calculate dimensions
            xyz=in[2];

            xyz_in=[
                    xyz[0] == "max" ? x : xyz[0],
                    xyz[1] == "max" ? y : xyz[1],
                    xyz[2] == "max" ? z : xyz[2]
                   ];
            
            //calculate translation
            t_xyz_in=[ 
                       -x/2 + wst + xyz_in[0]/2 + t_xyz[0], 
                       -y/2 + wst + xyz_in[1]/2 + t_xyz[1], 
                       -z/2 + wst + xyz_in[2]/2 + t_xyz[2] 
                     ];
            
            if ( in[0] == "c" ) {
              // ["c", pos[xyz], size[xyz], wst]
              translate(t_xyz_in)
                cube(xyz_in,true);
            } else if ( in[0] == "SC2" ) {
              // ["SC2", pos[xyz], size[xyz], wst, r[t,[c1,c2,c3,c4],b], otype]
              translate(t_xyz_in)
                SCube2(xyz_in,in[3], in[4], in[5], true);
            } else if ( in[0] == "SC" ) {
              // ["SC", pos[xyz], size[xyz], wst, r, rtype, otype]
              translate(t_xyz_in)
                SCube(xyz_in[0],xyz_in[1],xyz_in[2],in[3], in[4], in[5], in[6], true);
            }
          } else if ( in[0] == "MH" ) {
            // ["MH", pos[xyz], split_z, rot_z, size_xy]
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

module RCube2(size=[10,10,10],rounding=[0,[0,0,0,0],0],center=true) {
  // draws a solid cube which may have rounded edges
  //   size = [x, y, z] /gives outer dimensions
  //   rounding = [top rounding, [corner 1 rounding, c2r, c3r, c4r] bottom_rounding] /gives the radius for rounding the edges: all top or all bottom edges or individual vertical corners - ccw from top left

  //assert no negative size
  x=size[0];
  y=size[1];
  z=size[2];

  //assert no negative roundings
  r_tb=[ rounding[0] , rounding[2]  ];
  r_mid=[ rounding[1][0], rounding[1][1], rounding[1][2], rounding[1][3] ];
  
  xyz_uncenter = (center) ? [0,0,0] : [x/2,y/2,z/2];
  
  translate(xyz_uncenter) {
    if ( r_tb[0]+r_tb[1]+r_mid[0]+r_mid[1]+r_mid[2]+r_mid[3] == 0 ) {
      //no rounding at all
      cube([x,y,z],true);
    } else {
      fallback=1; //must be smaller than 1/2 the smallest wall
      
      hull() {
        translate( [  -(x/2 - (r_mid[0] != 0 ? r_mid[0] : (r_tb[0] == 0 ? fallback/2 : r_tb[0]))), 
                        y/2 - (r_mid[0] != 0 ? r_mid[0] : (r_tb[0] == 0 ? fallback/2 : r_tb[0])),
                        z/2 - (r_tb[0] == 0 ? fallback/2 : r_tb[0]) ] )       RCubeCorner(r_mid[0], r_tb[0], fallback);
        translate( [  -(x/2 - (r_mid[1] != 0 ? r_mid[1] : (r_tb[0] == 0 ? fallback/2 : r_tb[0]))),
                      -(y/2 - (r_mid[1] != 0 ? r_mid[1] : (r_tb[0] == 0 ? fallback/2 : r_tb[0]))),
                        z/2 - (r_tb[0] == 0 ? fallback/2 : r_tb[0]) ] )       RCubeCorner(r_mid[1], r_tb[0], fallback);
        translate( [    x/2 - (r_mid[2] != 0 ? r_mid[2] : (r_tb[0] == 0 ? fallback/2 : r_tb[0])),
                      -(y/2 - (r_mid[2] != 0 ? r_mid[2] : (r_tb[0] == 0 ? fallback/2 : r_tb[0]))),   
                        z/2 - (r_tb[0] == 0 ? fallback/2 : r_tb[0]) ] )       RCubeCorner(r_mid[2], r_tb[0], fallback);
        translate( [    x/2 - (r_mid[3] != 0 ? r_mid[3] : (r_tb[0] == 0 ? fallback/2 : r_tb[0])),   
                        y/2 - (r_mid[3] != 0 ? r_mid[3] : (r_tb[0] == 0 ? fallback/2 : r_tb[0])),   
                        z/2 - (r_tb[0] == 0 ? fallback/2 : r_tb[0]) ] )       RCubeCorner(r_mid[3], r_tb[0], fallback);

        translate( [  -(x/2 - (r_mid[0] != 0 ? r_mid[0] : (r_tb[1] == 0 ? fallback/2 : r_tb[1]))), 
                        y/2 - (r_mid[0] != 0 ? r_mid[0] : (r_tb[1] == 0 ? fallback/2 : r_tb[1])),
                      -(z/2 - (r_tb[1] == 0 ? fallback/2 : r_tb[1])) ] )      RCubeCorner(r_mid[0], r_tb[1], fallback);
        translate( [  -(x/2 - (r_mid[1] != 0 ? r_mid[1] : (r_tb[1] == 0 ? fallback/2 : r_tb[1]))),
                      -(y/2 - (r_mid[1] != 0 ? r_mid[1] : (r_tb[1] == 0 ? fallback/2 : r_tb[1]))),
                      -(z/2 - (r_tb[1] == 0 ? fallback/2 : r_tb[1])) ] )      RCubeCorner(r_mid[1], r_tb[1], fallback);
        translate( [    x/2 - (r_mid[2] != 0 ? r_mid[2] : (r_tb[1] == 0 ? fallback/2 : r_tb[1])),
                      -(y/2 - (r_mid[2] != 0 ? r_mid[2] : (r_tb[1] == 0 ? fallback/2 : r_tb[1]))),   
                      -(z/2 - (r_tb[1] == 0 ? fallback/2 : r_tb[1])) ] )      RCubeCorner(r_mid[2], r_tb[1], fallback);
        translate( [    x/2 - (r_mid[3] != 0 ? r_mid[3] : (r_tb[1] == 0 ? fallback/2 : r_tb[1])),   
                        y/2 - (r_mid[3] != 0 ? r_mid[3] : (r_tb[1] == 0 ? fallback/2 : r_tb[1])),   
                      -(z/2 - (r_tb[1] == 0 ? fallback/2 : r_tb[1]))] )       RCubeCorner(r_mid[3], r_tb[1], fallback);
      }
    }
  }
}

module RCubeCorner(r_z, r_xy, fallback_size=1) {
  // creates an geometrical form which has a rounding along the z-axis and antother rounding along the xy-axis
  // the size of the resulting forms is as follows:
  // | r_z | r_xy | specifics   | resulting form | size_xy | size_z |
  // | >0  |  0   |             | cylinder       | 2*r_z   | fallb  |
  // | >0  | >0   | r_z == r_xy | sphere         | 2*r_z   | 2*r_xy |
  // | >0  | >0   | r_z >= r_xy | TorusOutHalf   | 2*r_z   | 2*r_xy |
  // | >0  | >0   | r_z < r_xy  | NOT SUPPORTED  | n/a     | n/a    |
  // |  0  | >0   |             | inters. cyls.  | 2*r_xy  | 2*r_xy |
  // |  0  |  0   |             | cube           | fallb   | fallb  |
  //   r_z = radius of rounding along z-axis
  //   r_xy = radius of rounding along xy-axis
  //   fallback_size = the fallback length if langth can not be derived from rounding

  //echo("running RCubeCorner(r_z, r_xy, fallback_size)", "r_z:",r_z, "r_xy:",r_xy, "fallback_size:",fallback_size);
  if ( r_z > 0 ) {
    if ( r_xy == 0 ) {
      //echo("using cylinder");
      cylinder(fallback_size,r_z,r_z, true);
    } else if ( r_z == r_xy ) {
      //echo("using sphere");
      sphere(r_z,true);
    } else if ( r_z >= r_xy ) {
      //echo("using TorusOuterHalf");
      TorusOuterHalf( r_xy, r_z );
    } else {
      echo("r_z:",r_z, "r_xy:",r_xy);
      assert(true,"cannot create a RCubeCorner element for given r_z and r_xy"); 
    }
  } else {
    if ( r_xy > 0 ) {
      //echo("using cylinder intersection");
      intersection() {
        rotate([0,90,0]) cylinder(h=2*r_xy,r1=r_xy,r2=r_xy,center=true);
        rotate([90,0,0]) cylinder(h=2*r_xy,r1=r_xy,r2=r_xy,center=true);
      }
    } else {
      //echo("using cube");
      cube(fallback_size,true);
    }
  }
}

module Torus(r1, r2) {
  // creates a torus
  //   r1 = radius of the edge of the torus
  //   r2 = radius of the torus itself
  assert_greater_or_equal(r2/2,r1,"r1 > r2/2 in Torus");

  r_torus = r1;           // Radius   of  Torus
  r_total = r2 - r1;     // Radius   of  Torus overall 
    
  rotate_extrude(convexity = 10) // the value is the sides the finer
    translate([r_total, 0, 0])
      circle(r_torus); // the value is the sides
}

module TorusOuterHalf(r1, r2) {
  // creates a torus-like shape based on the outer half circle of what a torus would be based of
  // (bad explanation I know - create one and you'll understand)
  //   r1 = radius of the edge of the torus
  //   r2 = radius of the torus itself
  
  //echo("running TorusOuterHalf(r1, r2)", "r1:",r1, "r2:",r2);
  assert_greater_or_equal(r2,r1,"r1 > r2 in TorusOuterHalf");
  
  r_torus = r1;
  r_total = r2 - r1;
    
  rotate_extrude(convexity = 10) { // the value is the sides the finer
    translate([r_total, 0, 0]) {
      difference() {
        circle(r_torus);
        translate([-r_torus,0,0]) square([r_torus*2,r_torus*2], true);
      }
    }
  }
}

module CrossBox(x,y,z,r) {
  // helper function, currently not needed
	cube(size=[x-2*r,y-2*r,z],center=true);
	cube(size=[x-2*r,y,z-2*r],center=true);
	cube(size=[x,y-2*r,z-2*r],center=true);
}

module MagHolder(z,split_z,rotate=0,xy=5) {
  // creates a holder for cube neodym magnets with 4mm side length
  mag_size=4;
  min_wst=0.5;
  assert_greater_or_equal(xy,mag_size+2*min_wst,"MagHolder: xy must be greater than mag_size + 2*min_wst");
  
  rotate([0,0,rotate]) difference() {
    cube([xy,xy,z],true);
    translate([0,0,-z/2+split_z])
      cube([mag_size,mag_size,2*mag_size],true);
  }
}

module PyramidStump(size, narrowing) {
  // creates a pyramid stump with a top area whose four edges are pushed inwards by narrowing
  //   size = [x, y, z] /gives outer dimensions
  //   narrowing = amount by which edges of pyramid top area are pushed inwards
  
  x=size[0];
  y=size[1];
  z=size[2];
  
  polyhedron(
    points = [ [  x/2,  y/2, 0 ],   //0
               [  x/2, -y/2, 0 ],  //1
               [ -x/2, -y/2, 0 ], //2
               [ -x/2,  y/2, 0 ],  //3
               
               [  x/2-narrowing,  y/2-narrowing, z],   //4
               [  x/2-narrowing, -y/2+narrowing, z],  //5
               [ -x/2+narrowing, -y/2+narrowing, z], //6
               [ -x/2+narrowing,  y/2-narrowing, z]   //7
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