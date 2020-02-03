//Pendiente:
// - El recorte de arriba se imprimirá girado, apoyado en la parte de los puertos

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
inhibitionzone_height_noups =boardw2hat_thickness-board_thickness;
pin_space = 3;//2.2; // the min space that the throughhole components require underneath - Height of the mounts (up and down)
//$fn = 100; // how detailed the circular components are (holes + mounts), not super important
$fn = 20; // low detailed for developing. Replace this value to 100 before generating the stl printing model.
extension = 20; // extension to lengths so case can be subtractiveley created
inhibitionzone_height= 33.5; //inhibition zone for 3g and pivoyager hats
case_thickness = 2; // sets the case thickness
pil = 85.5; // this is the length of the pi board only
pid = 56; // this is the width / depth of the pi board only
pih = board_thickness;
sd_height = pin_space + case_thickness + board_thickness; // is how tall the sd card part sticking out is so if you increase it will cut more out for case
mount_pin_height = 2*board_thickness + 2*case_thickness + pin_space + inhibitionzone_height; // this is the most awkward one of the set as it sets the mount point pin size
// I want a rounded box. I will achieve it using Minkowsky addition
mink_functs_height = 0.5; //the height we are using in the cylinders, in Minkowsky functions. Not importante, only keep low
case_int_radio = 3; //internal radio or the cases corner. Used in Minkowsky functions
nuts_height = 2; //the height of the nuts holes (and the screw heads)
// Added Space For Battery And Hats
battd = 20; //width / depth space for battery
upscardd = 29.5; //the UPS board width / depth
eth_height = 13.6;
usbs_height = 15.6;
intrabatth = 5; //height of the separation inserted between battery and the raspberry
y_antenna_eth_conn = 9; //y axis of the antenna over the eth port (both antennas are symetrical in the y axis).
x_to_first_mount_center = 22.2;
mount_diameter = 7;
screw_head_diam = 5; // screw head hole, will be over the case
x_step_begin = x_to_first_mount_center-screw_head_diam/2; //the UPS USB step initial point is just before screw hole
antennabigradio = 5;
antennalittlediameter = 9;

// comment here what you dont want to generate
translate([-40,0,inhibitionzone_height + case_thickness + board_thickness]) rotate([0,180,0]) intersection(){rpi4_case(); topSelector();} // top of case
translate([-90,120,case_thickness]) rotate([0,0,0]) difference(){rpi4_case(); topSelector(); } // bottom of case
//translate([-pil,pid+case_thickness*2+5]) rpi4_case(); // the whole unsplit case
//translate([extension+17.44+30,pid+case_thickness*2+5,0]) rpi4andbatt(); // the raspberry pi 4 and associated tolerances
//translate([200,200,0]) topSelector();
// here follows all the modules used to generate what you want.
// topSelector();
module topSelector() 
  translate([-case_thickness,0,0]) {
    difference(){ // this difference selects the top and bottom parts of the case with a small lip for the IO
      union(){
        cube([pil-case_int_radio-case_thickness,pid+battd+case_thickness,inhibitionzone_height+board_thickness]);  // test hull
        translate([0,0,inhibitionzone_height+board_thickness-pin_space-case_thickness])
          cube([pil+case_thickness,pid+battd+case_thickness,pin_space+case_thickness]);  // just under top of case (to take the mounts).
        translate([0,-case_thickness,inhibitionzone_height+board_thickness])
          cube([pil+2*case_thickness,pid+battd+2*case_thickness,case_thickness]);  // top top of case 
        translate([pil-case_int_radio-case_thickness,pid+battd+2*case_thickness-upscardd,inhibitionzone_height_noups+board_thickness-pin_space-case_thickness])
          cube([2*case_thickness+case_int_radio,upscardd-case_thickness,3*case_thickness+pin_space]);  // ups corner
        translate([0,pid+battd+case_thickness,3.6+board_thickness])
          cube([pil+2*case_thickness,case_thickness,inhibitionzone_height-(3.6)+board_thickness+case_thickness]); // over hdmi side
        }
      union(){
        cube([case_thickness+2*case_int_radio,18.45+battd+case_thickness,board_thickness+eth_height]); //Over Eth case
        translate([0,18.45+battd+case_thickness,0]) cube([case_thickness+2*case_int_radio,pid+battd-(18.45+battd),board_thickness+usbs_height]); //Over USB case
        translate([pil+case_thickness-case_int_radio,0,inhibitionzone_height+board_thickness-pin_space]) cube([case_int_radio,case_int_radio,pin_space]);
        }
      }
    translate([0,pid+battd,3.6+board_thickness])
      cube([case_thickness+case_int_radio,case_thickness,inhibitionzone_height-(3.6)+board_thickness+case_thickness]); // over hdmi side corner
    }

module basic_case() //this is the shell case. We will substract the rpi model from it.
  difference(){ // subtracts the rpi4 step from a cube to generate the basic case
    minkowski(){
      translate([(case_int_radio+case_thickness),(case_int_radio+case_thickness),0]){
        cube([pil+(2*case_thickness)-2*(case_int_radio+case_thickness),
          pid+battd+(3*case_thickness)-2*(case_int_radio+case_thickness),
          pin_space+inhibitionzone_height+board_thickness+(2*case_thickness)-mink_functs_height]);
        } // the case itself
      cylinder(mink_functs_height, r=case_int_radio+case_thickness);
    }
    translate([x_step_begin+case_thickness,upscardd+battd+(3*case_thickness), pin_space+inhibitionzone_height_noups+board_thickness+(2*case_thickness)]) //avoid the antenna connector
      cube([pil-x_step_begin+case_thickness,pid-upscardd,inhibitionzone_height-inhibitionzone_height_noups]);
  }
module rpi4_case() //the whole case
  difference(){ // subtracts the rpi4 model from a cube to generate the case
    translate([-case_thickness,-case_thickness,-(case_thickness + pin_space)]) basic_case(); // the case itself
    translate([0,(battd+case_thickness),0]) {
      union(){
        rpi4andbatt();
        pins(); // generating the pins themselves so the holes can be inhibited
        nuts();
        }
      }
    }

module rpi4andbatt() //this module adds the battery space
  difference() {
    union(){
      rpi4();
      translate([intrabatth,-case_thickness,0])
          cube([(pil-2*intrabatth), case_thickness, (inhibitionzone_height+board_thickness-intrabatth)]); // nerves between batt and rpi
      translate([0,-(battd+case_thickness),-pin_space])
      minkowski(){
        translate([case_int_radio,case_int_radio,0])
          cube([pil-2*case_int_radio,battd-2*case_int_radio,pin_space+inhibitionzone_height+board_thickness-mink_functs_height]);
          cylinder(mink_functs_height, r=case_int_radio);
      }                 
    }
  }  
module rpi4() {
  difference() { // this creates the mount holes and the UPS connector corner
    translate([0,0,board_thickness]) {  // two translations cancel out but make maths simpler before they do
      translate([0,0,-(board_thickness)]) union() {  // the translation which ^ cancels out
        // These two Minkowsky adds the boards just to substract their holes
        minkowski() {
          translate([case_int_radio,case_int_radio,0])
            cube([pil-2*case_int_radio,pid-2*case_int_radio,boardw1hat_thickness-mink_functs_height]); // first 2 boards only (not the underpins)
          cylinder(mink_functs_height, r=case_int_radio);
          }
        minkowski() {
          translate([case_int_radio,case_int_radio,0])
            cube([pil-2*case_int_radio,upscardd-2*case_int_radio,boardw2hat_thickness-mink_functs_height]); // ups cube, overlaps the first cube
          cylinder(mink_functs_height, r=case_int_radio);
          }
        }
      // these are the big surface level components
      translate([-(2.81+extension),2.15,0]) cube([21.3+extension,16.3,eth_height]);   // Ethernet port Acaba en 18.45
      translate([-(2.81+extension),22.6,0]) cube([17.44+extension,13.5,usbs_height]);    // USB 3.0     Deja 4.15. Acaba en 36.1
      translate([-(2.81+extension),19.6,18.1]) cube([17.44+extension,10,5]);    // Over USB connection to 3G card
      translate([-(2.81+extension),40.6,0]) cube([17.44+extension,13.5,usbs_height]);  // USB 2.0  Deja 4.5
      translate([27.36,1,0]) cube([50.7,5.0,8.6+extension]);                    // GPIO pins
      translate([21,7.15,0]) cube([5.0,5.0,8.6+extension]);                     // Power over ethernet pins
      translate([48.0,16.3,0]) cube([15.0,15.0,2.5]);                           // cpu
      // translate([67.5,6.8,0]) cube([10.8,13.1,1.8]);                         // onboard wifi
      translate([79,17.3,0]) cube([2.5,22.15,5.4+extension]);                   // display connector
      translate([69.1,pid,0]) cube([9.7,extension,3.6]);                     // USB type C power
      translate([55.0,pid,0]) cube([7.95,extension,3.9]);                    // Micro HDMI0
      translate([41.2,pid,0]) cube([7.95,extension,3.9]);                    // Micro HDMI1
      //      translate([37.4,34.1,0]) cube([2.5,22.15,5.4+extension]);         // CSI camera connector, I dont need here
      translate([26.9,pid,0]) cube([8.5,extension,6.9]);                // Audio jack
      // other components (not surface ones)
      translate([42,pid,14.5]) cube([13,extension,3]);                         // SIM Card slot       
      translate([pil,7,boardw2hat_thickness-board_thickness]) cube([extension,3,1.5]);  // UPS button, height similar to UPS USB connector            
      translate([pil,22.4,-(board_thickness+sd_height)]) cube([extension,11.11,sd_height]); // SD card (poking out)
      // Batt side holes
      holepacing3=14;
      for (n=[0:4]) { // lateral holes
        translate([14+n*holepacing3,-battd,inhibitionzone_height/2]) rotate([90,30,0]) scale([1,5,1]) cylinder(extension, d=5, center=false);
      translate([14,pid,inhibitionzone_height/2]) rotate([270,60,0]) scale([5,1,1]) cylinder(extension, d=5, center=false);
      }
      // Under and below big spaces
      difference() { // this creates the mount points around the mount holes esp the underneath ones
        union() {
          minkowski() {
            translate([case_int_radio,case_int_radio,0])
              cube([pil-2*case_int_radio, pid-2*case_int_radio, inhibitionzone_height-mink_functs_height]); // cpu
            cylinder(mink_functs_height, r=case_int_radio);
            }
          translate([0,0,-(pin_space+board_thickness)]) minkowski() {
            translate([case_int_radio,case_int_radio,0])
              cube([pil-2*case_int_radio, pid-2*case_int_radio, pin_space-mink_functs_height]); // underpins only
            cylinder(mink_functs_height, r=case_int_radio);
            }  
          }
        mounts(); // the material which is above and below the board to keep it in place which the pins go through
        }
      } // end of translation cancel
    union() {
      translate([x_step_begin-case_thickness,upscardd, inhibitionzone_height_noups+board_thickness]) //create corner of UPS connector. Z must avoid the antenna connector
        cube([pil+(1*case_thickness)-x_step_begin,pid-upscardd+case_thickness,inhibitionzone_height-inhibitionzone_height_noups+case_thickness]);
      pins(); // the hole which will be screwed into to put both halves of the case and board together
      }
    }
  translate([30,upscardd,inhibitionzone_height_noups+board_thickness]) cube([9,case_thickness,5]);    // UPS-USB connector, must be after the corner difference 
  translate([53,7.8,0]) { // the air holes dont need the first translate and must be after the ups connector corner difference.
    scale([10,1,1]){ // scale 10 of d=5 moves 12.5 less than scale 15
      translate([0,0,-extension-pin_space])  cylinder(extension,d=5, center=false);      // under-side air hole
      translate([0,40,-extension-pin_space]) cylinder(extension,d=5, center=false);      // under-side air hole
      translate([0,-4,inhibitionzone_height])  cylinder(extension,d=5, center=false);      // over-side middle (little) air hole
      }
    holepacing1=10;
    scale([15,1,1]) for (n=[0:2]) {      // under-side air holes
      translate([-0.6,10+holepacing1*n,-extension-pin_space]) cylinder(extension,d=5, center=false);
      }
    scale([12,1,1]) {      // over-side air holes
      for (n=[0:1]) translate([0,-25+10*n,inhibitionzone_height]) cylinder(extension,d=5, center=false);
      for (n=[0:1]) translate([0,6+10*n,inhibitionzone_height]) cylinder(extension,d=5, center=false);
      }    
    holepacing2=10;
    scale([10,1,1]) for (n=[0:1]) //over-side under UPS step      
      translate([0,30+n*holepacing2,inhibitionzone_height_noups]) cylinder(extension+inhibitionzone_height-inhibitionzone_height_noups,d=5, center=false);
    }
  // antenna holes
  translate([case_thickness+antennabigradio,y_antenna_eth_conn,inhibitionzone_height])  cylinder(extension,d=antennalittlediameter, center=false);
  translate([case_thickness+antennabigradio,pid-y_antenna_eth_conn,inhibitionzone_height])  cylinder(extension,d=antennalittlediameter, center=false);
  }
module mounts() {
  // translate([1.25,1.25,(0.5*mount_pin_height)-(board_thickness+case_thickness+pin_space)]) // this is to move all the mounts
    // for(n=[0:1]) for(m=[0:1]) translate([22.2+58*n,2+49*m,0]) cylinder(mount_pin_height,d=mount_diameter, center=true);     // mount top/bot-r/l
  translate([1.25,1.25,-(board_thickness+case_thickness)]) 
    for(n=[0:1]) for(m=[0:1]) translate([22.2+58*n,2+49*m,0]) cylinder(pin_space,d=mount_diameter, center=true);     // mount bot-r/l
  translate([1.25,1.25,inhibitionzone_height-0.5*pin_space]) 
    for(n=[0:1]) translate([22.2+58*n,2,0]) cylinder(pin_space,d=mount_diameter, center=true);     // mount top-r/l
  translate([1.25,1.25,inhibitionzone_height_noups-0.5*pin_space]) 
    for(n=[0:1]) translate([22.2+58*n,2+49,0]) cylinder(pin_space,d=mount_diameter, center=true);     // mount top-r/l
  }
module pins()
  translate([1.25,1.25,(0.5*mount_pin_height)-(board_thickness+case_thickness+pin_space)]) // this is to move all the pins
    for(n=[0:1]) for(m=[0:1]) translate([22.2+58*n,2+49*m,0]) cylinder(mount_pin_height,d=2.5, center=true);     // hole top/bot-r/l
module nuts()
  // Max 6 mm de diameter. The screw may measure 5 mm. The nuts vary from 5.45 to 5.77. Height of the nuts between 1.75 and 2
  translate([1.25,1.25,0]) { // this is to move all the nut holes
    for(n=[0:1]) for(m=[0:1]) translate([x_to_first_mount_center+58*n,2+49*m,-(case_thickness+pin_space)]) linear_extrude(height=nuts_height) circle(d=6.2,$fn=6);
    for(m=[0:1]) translate([x_to_first_mount_center+58*m,2,(inhibitionzone_height+board_thickness+case_thickness)-nuts_height]) linear_extrude(height=nuts_height) circle(d=screw_head_diam);
    for(m=[0:1]) translate([x_to_first_mount_center+58*m,2+49,(inhibitionzone_height_noups+board_thickness+case_thickness)-nuts_height]) linear_extrude(height=nuts_height) circle(d=screw_head_diam);
    }