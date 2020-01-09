// Openscad model of a Raspberry pi 4 case with space and holes for pivoyager and pilotiog hats.
// Original file maintained in https://github.com/Vayatoalla/OpenScadModels
// Based on a design by George Onoufriou (https://github.com/DreamingRaven/RavenSCAD/blob/master/LICENSE)

// |-=========---------| <-The back right of the board is the point everything else is relative to
// | o            o    |
// | o            o    |
// ||_|----------------|

board_thickness = 1.5; // the space for the board itself only
boardw1hat_thickness = 15; // the space of the rpi board with the first hat
boardw2hat_thickness = 28; // the space of the rpi board with two hats
pin_space = 3;//2.2; // the min space that the throughhole components require underneath
//$fn = 100; // how detailed the circular components are (holes + mounts), not super important
$fn = 20; // low detailed for developing. Replace this value to 100 before generating the stl printing model.
extension = 20; // extension to lengths so case can be subtractiveley created
//inhibitionzone_height = 12; // creates an inhibition zone for surface components
inhibitionzone_height= 33.5; //inhibition zone for 3g and pivoyager hats
case_thickness = 2;//2; // sets the case thickness
pil = 85.5; // this is the length of the pi board only
pid = 56; // this is the width / depth of the pi board only
pih = board_thickness;
sd_height = pin_space + case_thickness + board_thickness; // is how tall the sd card part sticking out is so if you increase it will cut more out for case
mount_pin_height = 2*board_thickness + 2*case_thickness + pin_space + inhibitionzone_height; // this is the most awkward one of the set as it sets the mount point pin size
// I want a rounded box. I will achieve it using Minkowsky addition
mink_functs_height = 0.5; //the height we are using in the cylinders, in Minkowsky functions. Not importante, only keep low
case_int_radio = 3; //internal radio or the cases corner. Used in Minkowsky functions

// Added Space For Battery And Hats
battd = 20; //width / depth space for battery
upscardd = 29.5; //the UPS board width / depth
intrabatth = 5; //height of the separation inserted between battery and the raspberry
x_to_avoid_antenna_conn = 31;
y_antenna_eth_conn = 9; //y axis of the antenna over the eth port (both antennas are symetrical in the y axis).
inhibitionzone_height_noups =20;

// uncomment here what you dont want to generate
 translate([-40,0,inhibitionzone_height + case_thickness + board_thickness]) rotate([0,180,0]) intersection(){rpi4_case(); topSelector();} // top of case
 translate([30,0,case_thickness]) rotate([0,-90,0]) difference(){rpi4_case(); topSelector(); } // bottom of case
// translate([-pil,pid+case_thickness*2+5]) rpi4_case(); // the whole unsplit case
translate([extension+17.44+30,pid+case_thickness*2+5,0]) rpi4andbatt(); // the raspberry pi 4 and associated tolerances
translate([200,200,0]) topSelector();
// here follows all the modules used to generate what you want.
module topSelector()
{
  difference(){ // this difference selects the top and bottom parts of the case with a small lip for the IO
    translate([-case_thickness,0,0]) cube([pil+2*case_thickness,pid+battd+case_thickness,pin_space+inhibitionzone_height+case_thickness]);  // test hull
    translate([-case_thickness,0,0]) cube([case_thickness,pid+battd+case_thickness,board_thickness]);
  }
}

module basic_case(){ //this is the shell case from that we will substract the rpi model.
    difference(){ // subtracts the rpi4 model from a cube to generate the case
      minkowski(){
        translate([(case_int_radio+case_thickness),(case_int_radio+case_thickness),0]){
          cube([pil+(2*case_thickness)-2*(case_int_radio+case_thickness),
            pid+battd+(3*case_thickness)-2*(case_int_radio+case_thickness),
            pin_space+inhibitionzone_height+board_thickness+(2*case_thickness)-mink_functs_height]);} // the case itself
        cylinder(mink_functs_height, r=case_int_radio+case_thickness);
      }
      translate([x_to_avoid_antenna_conn+2*case_thickness,upscardd+battd+(3*case_thickness), pin_space+inhibitionzone_height_noups+board_thickness+(2*case_thickness)]) //avoid the antenna connector
       cube([pil+(0*case_thickness)-x_to_avoid_antenna_conn,pid-upscardd,inhibitionzone_height-inhibitionzone_height_noups]);
  }
}
module rpi4_case()
{
  difference(){ // subtracts the rpi4 model from a cube to generate the case
    translate([-case_thickness,-case_thickness,-(case_thickness + pin_space)])
    basic_case(); // the case itself
    translate([0,(battd+case_thickness),0]) {
        union(){
            rpi4andbatt();
            pins(); // generating the pins themselves so the holes can be inhibited
        }
    }
  }
}
module rpi4andbatt(){ //this module adds the space battery
  difference() {
    union(){
      rpi4();
      translate([intrabatth,-case_thickness,0])
          cube([(pil-2*intrabatth), case_thickness, (inhibitionzone_height+board_thickness-intrabatth)]); // the case itself
      translate([0,-(battd+case_thickness),-pin_space])
      minkowski(){
        translate([case_int_radio,case_int_radio,0])
          cube([pil-2*case_int_radio,battd-2*case_int_radio,pin_space+inhibitionzone_height+board_thickness-mink_functs_height]);
          cylinder(mink_functs_height, r=case_int_radio);
      }                 
    }

  }
  
}
module rpi4() {
  difference() { // this creates the mount holes and the UPS connector corner
    translate([0,0,board_thickness]) {  // two translations cancel out but make maths simpler before they do
      translate([0,0,-(board_thickness)]) union() {  // the translation which ^ cancels out
        minkowski() {
          translate([case_int_radio,case_int_radio,0])
            cube([pil-2*case_int_radio,pid-2*case_int_radio,boardw1hat_thickness-mink_functs_height]); // first 2 boards only (not the underpins)
          cylinder(mink_functs_height, r=case_int_radio);
        }
        minkowski() {
          translate([case_int_radio,case_int_radio,0])
            cube([pil-2*case_int_radio,upscardd-2*case_int_radio,boardw2hat_thickness-mink_functs_height]); // the 3 boards only (not the underpins)
          cylinder(mink_functs_height, r=case_int_radio);
        }
      }
      // these are the big surface level components
      translate([-(2.81+extension),2.15,0]) cube([21.3+extension,16.3,13.6]);   // Ethernet port
      translate([-(2.81+extension),22.6,0]) cube([17.44+extension,13.5,24]);    // USB 3.0 + connection to 3G card
      translate([-(2.81+extension),40.6,0]) cube([17.44+extension,13.5,15.6]);  // USB 2.0
      translate([27.36,1,0]) cube([50.7,5.0,8.6+extension]);                    // GPIO pins
      translate([21,7.15,0]) cube([5.0,5.0,8.6+extension]);                     // Power over ethernet pins
      translate([48.0,16.3,0]) cube([15.0,15.0,2.5]);                           // cpu
      translate([67.5,6.8,0]) cube([10.8,13.1,1.8]);                            // onboard wifi
      translate([79,17.3,0]) cube([2.5,22.15,5.4+extension]);                   // display connector
      translate([69.1,50,0]) cube([9.7,7.4+extension,3.6]);                     // USB type c power
      translate([55.0,50,0]) cube([7.95,7.8+extension,3.9]);                    // Micro HDMI0
      translate([41.2,50,0]) cube([7.95,7.8+extension,3.9]);                    // Micro HDMI1
      //      translate([37.4,34.1,0]) cube([2.5,22.15,5.4+extension]);                 // CSI camera connector, I dont need this now
      translate([26.9,43.55,0]) cube([8.5,14.95+extension,6.9]);                // Audio jack
      translate([42,50,12]) cube([13,7.8+extension,3]);                    // SIM Card slot
            
      translate([85,22.4,-(board_thickness+sd_height)]) cube([2.55+extension,11.11,sd_height]); // SD card (poking out)

      difference() { // this creates the mount points around the mount holes esp the underneath ones
        union() {
          translate([0,0,0]) 
          minkowski() {
            translate([case_int_radio,case_int_radio,0])
              cube([pil-2*case_int_radio, pid-2*case_int_radio, inhibitionzone_height-mink_functs_height]); // cpu
            cylinder(mink_functs_height, r=case_int_radio);
          }
          translate([0,0,-(pin_space+board_thickness)])
          minkowski() {
            translate([case_int_radio,case_int_radio,0])
              cube([pil-2*case_int_radio, pid-2*case_int_radio, pin_space-mink_functs_height]); // underpins only
            cylinder(mink_functs_height, r=case_int_radio);
          }  
        }
        mounts(); // the material which is above and below the board to keep it in place which the pins go through
      }
    } // end of translation cancel
    union() {
      translate([x_to_avoid_antenna_conn,upscardd, inhibitionzone_height_noups+board_thickness]) //create corner of UPS connector. Must avoid the antenna connector
        cube([pil+(1*case_thickness)-x_to_avoid_antenna_conn,pid-upscardd+case_thickness,inhibitionzone_height-inhibitionzone_height_noups+case_thickness]);
      pins(); // the hole which will be screwed into to put both halves of the case and board together
    }
  }
  translate([53,7.8,0]) { // the air holes dont need the first translate and must be after the ups connector corner difference.
    translate([0,-2,inhibitionzone_height])  cylinder(extension,d=5, center=false);      // over-side air hole
    scale([10,1,1]){ // scale 10 of d=5 moves 12.5 less than scale 15
      translate([0,0,-extension-pin_space])  cylinder(extension,d=5, center=false);      // under-side air hole
      translate([0,40,-extension-pin_space]) cylinder(extension,d=5, center=false);      // under-side air hole
      translate([0,-2,inhibitionzone_height])  cylinder(extension,d=5, center=false);      // over-side air hole
    }
    scale([15,1,1]) {
      translate([-0.6,-24,-extension-pin_space]) cylinder(extension,d=5, center=false);      // under-side air hole
      translate([-0.6,-15,-extension-pin_space]) cylinder(extension,d=5, center=false);      // under-side air hole
      translate([-0.6,10,-extension-pin_space]) cylinder(extension,d=5, center=false);      // under-side air hole
      translate([-0.6,20,-extension-pin_space]) cylinder(extension,d=5, center=false);      // under-side air hole
      translate([-0.6,30,-extension-pin_space]) cylinder(extension,d=5, center=false);      // under-side air hole
    }
    scale([12,1,1]) {
      translate([0,-22,inhibitionzone_height]) cylinder(extension,d=5, center=false);      // over-side air hole
      translate([0,-12,inhibitionzone_height]) cylinder(extension,d=5, center=false);      // over-side air hole
      translate([0,8,inhibitionzone_height]) cylinder(extension,d=5, center=false);      // over-side air hole
      translate([0,18,inhibitionzone_height]) cylinder(extension,d=5, center=false);      // over-side air hole
    }
    scale([9,1,1]) {
      translate([0.5,30,inhibitionzone_height_noups]) cylinder(extension+inhibitionzone_height-inhibitionzone_height_noups,d=5, center=false);
      translate([0.5,40,inhibitionzone_height_noups]) cylinder(extension+inhibitionzone_height-inhibitionzone_height_noups,d=5, center=false);      // over-side air hole
    }
  }
  translate([3,y_antenna_eth_conn,inhibitionzone_height])  cylinder(extension,d=9, center=false);
  translate([3,pid-y_antenna_eth_conn,inhibitionzone_height])  cylinder(extension,d=9, center=false);
}

module mounts(){
  translate([1.25,1.25,(0.5*mount_pin_height)-(board_thickness+case_thickness+pin_space)]){ // this is to move all the pins
          translate([22.2,2,0]) cylinder(mount_pin_height,d=5.9, center=true);     // mount top-r
          translate([22.2,51.1,0]) cylinder(mount_pin_height,d=5.9, center=true);  // mount bot-r
          translate([80.2,2,0]) cylinder(mount_pin_height,d=5.9, center=true);     // mount top-l
          translate([80.2,51.1,0]) cylinder(mount_pin_height,d=5.9, center=true);  // mount bot-l
        }
}

module pins(){
  translate([1.25,1.25,(0.5*mount_pin_height)-(board_thickness+case_thickness+pin_space)]){ // this is to move all the pins
    translate([22.2,2,0]) cylinder(mount_pin_height,d=2.5, center=true);     // hole  top-r
    translate([22.2,51.1,0]) cylinder(mount_pin_height,d=2.5, center=true);  // hole  bot-r
    translate([80.2,2,0]) cylinder(mount_pin_height,d=2.5, center=true);     // hole  top-l
    translate([80.2,51.1,0]) cylinder(mount_pin_height,d=2.5, center=true);  // hole  bot-l
  }
}
