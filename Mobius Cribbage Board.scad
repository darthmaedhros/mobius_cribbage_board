// Mobius Cribbage Board
//
// Modified from Swirl.scad by Stone Age Sculptor
// Original License: CC0 (Public Domain)
//
// Added cribbage board holes for pegging and column separating grooves
// Modified grooves to avoid intersecting with markers/numbers

/* [Common settings] */

// Total size.
size = 200; // [20:200]

// Radius of the edge of a solid base shape or size of separate tubes.
round_edge = 3; // [0:0.1:5]

// Radius of the circle for smoothing sharp edges.
round_sharp_edge = 0.2; // [0.0:0.1:2.0]

/* [Möbius shape settings] */

// Width of the base shape that is used to make the ring.
width = 15; // [2:40]

// Number of twists of the base shape.
twists = 1; // [0:30]

// Number of edges for a solid base shape or the number of tubes.
points = 2; // [1:15]

// Make a solid part of the base shape or separate tubes.
enable_solid = true;

// Make the edges round or squared.
enable_round_edge = false;

// Fill the torus inside.
enable_torus_fill = false;

/* [Cribbage Board Settings] */

// What to render
render_mode = 6; // [0:Mobius Strip Only, 1:Hole Cylinders Only, 2:Both (for visualization), 3:Markers Only, 4:Holes and Markers, 5:Strip Holes and Markers, 6:All with Grooves, 7:Grooves Only, 8:Edge Decoration Only]

// Number of columns of holes
cribbage_columns = 4; // [1:6]

// Total number of rows of holes (60 holes x 2 sides = 120 total positions)
cribbage_rows = 60; // [30:121]

// Diameter of cribbage holes
hole_diameter = 3.1; // [0.5:0.1:10.0]

// Length of hole cylinders (should be longer than strip width)
hole_length = 10; // [10:50]

enable_edge_decoration = true;

/* [Groove Settings] */

// Enable column separating grooves
enable_grooves = true;

// Width of the grooves (how wide the groove is)
groove_width = 0.9; // [0.2:0.1:2.0]

// Length of groove segments (how long the cylinders are)
groove_segment_length = 1.0; // [0.3:0.1:3.0]

// Gap around markers 
marker_gap_spacing = 4.0; // [0.1:0.1:10]

/* [Marker Settings] */

// Enable markers every N holes
marker_interval = 5; // [1:10]

// Width of marker lines (how wide the line is)
marker_width = 1.2; // [0.2:0.1:2.0]

// Height of marker lines (how tall/thick they are)
marker_height = 1.0; // [0.1:0.1:5.0]

// Depth of marker lines (how far they are inset into the surface)
marker_depth = 0; // [0.0:0.05:0.5]

// Length of marker lines (should span all columns plus extra)
marker_length = width*2; // [15:40]

/* [Hidden] */

// These value have been choosen to get some reasonable
// speed for the preview and the render.
// But they are not good enough when there are many twists.
$fa = $preview ? 2 : 0.8;
$fs = $preview ? 1 : 0.5;

// Angle step in degrees for the Möbius shape.
// When there are many twists, then the step should be smaller.
rough_step = 5 - ( min(20,twists) / 7);
fine_step  = 2 - ( min(20,twists) / 40);
step = $preview ? rough_step : fine_step;

// Adjust the radius, to avoid that it is zero.
work_round_edge = (round_edge == 0) ? 0.1 : round_edge;

// Separating the edge offsets for non-round edge case.
square_overhang = 1;

edge_offset = (enable_round_edge) ?  0 : work_round_edge - square_overhang;


// Main rendering logic
if (render_mode == 0) {
  // Render only the Mobius strip
  Mobius();
} else if (render_mode == 1) {
  // Render only the hole cylinders
  color("red") CribbageHoleCylinders();
} else if (render_mode == 2) {
  // Render both for visualization
  Mobius();
  color("red", 0.5) CribbageHoleCylinders();
} else if (render_mode == 3) {
  // Render only the markers
  color("blue") CribbageMarkers();
} else if (render_mode == 4) {
  // Render holes and markers
  color("red") CribbageHoleCylinders();
  color("blue") CribbageMarkers();
} else if (render_mode == 5) {
  // Render all for complete visualization
  Mobius();
  color("red", 0.5) CribbageHoleCylinders();
  color("blue", 0.7) CribbageMarkers();
} else if (render_mode == 6) {
  // Render everything including grooves
  Mobius();
  color("red", 0.5) CribbageHoleCylinders();
  color("blue", 0.7) CribbageMarkers();
  if (enable_grooves) {
    color("green", 0.6) CribbageGrooves();
  }
  if (enable_edge_decoration) {
          color("purple") CubeEdgeDecoration();
      }
} else if (render_mode == 7) {
  // Render only the grooves
  if (enable_grooves) {
    color("green") CribbageGrooves();
  }
  }
  else if (render_mode == 8) {
      // Render only the cube decorations
      if (enable_edge_decoration) {
          color("purple") CubeEdgeDecoration();
      }
}

module CribbageGrooves() {
    // Create grooves between each column pair
    for(groove_pos = [-1:cribbage_columns-1]) {
      // Calculate groove offset position (between columns)
      // Position groove between column groove_pos and groove_pos+1
      groove_offset = ((groove_pos + 0.5) / (cribbage_columns - 1) - 0.5) * (width * 1.5);
 
    // Create regular continuous groove
        CreateFullGroove(groove_offset, work_round_edge + groove_width/4);
        CreateFullGroove(groove_offset, -(work_round_edge + groove_width/4));
  }
}


module CreateFullGroove(offset, surface_offset) {
  // Create a continuous groove that follows the Möbius strip path
  // surface_offset determines which surface (positive = upper, negative = lower)
  union() {
    for(angle=[0:-step:-360]) {  // Changed to go clockwise
      hull() {
        CreateGrooveSlice(angle, offset, surface_offset);
        CreateGrooveSlice(angle - step, offset, surface_offset);  // Changed to subtract step
      }
    }
  }
}

module CreateGrooveSlice(angle, offset, surface_offset) {
  // Create one slice of the groove at the given angle and offset
  // surface_offset positions the groove on upper or lower surface
  rotate([0, 0, angle])
    translate([size/2 - width - work_round_edge, 0, 0])
      rotate([90, twists * angle / points, 0])
        translate([offset, surface_offset, 0])  // surface_offset should be on Y-axis, not Z-axis
          rotate([0, 0, 90])  // Orient groove to cut into the surface properly
            CreateGrooveShape();
}

module CreateGrooveShape() {
  // Create the cross-sectional shape of the groove
  // This should only be deep enough for one surface
  cylinder(d=groove_width, h=groove_segment_length, center=true, $fn=8);
}

module CribbageMarkers() {
  // Calculate angle per hole to distribute evenly around the strip
  angle_per_hole = -360 / cribbage_rows;  // Changed to negative for clockwise
  
  // Create markers at every marker_interval holes
  for(row = [0:marker_interval:cribbage_rows-1]) {
    // Calculate angle for this marker (same as hole positioning)
    marker_angle = (row + 0.5) * angle_per_hole;
    
    // Upper surface: normal numbering (0, 5, 10, 15, etc.)
    upper_text = (row == 0) ? "START/FINISH" :
                 str(row);
    
    // Lower surface: offset numbering (60, 5, 10, 15, etc.)
    // For cribbage, the opposite side typically shows 60 points ahead
    lower_row = (row) % 60;  // Changed: offset by 30 and wrap at 60
    lower_text = (lower_row == 30) ? "S" :  // S at 30 on the offset side
                 str(lower_row + 60);
    
    // Create upper surface marker with gap
    CreateMarkerSlice(marker_angle, work_round_edge - marker_depth, upper_text, true, row);
    // Create lower surface marker with gap
    CreateMarkerSlice(marker_angle, -(work_round_edge - marker_depth), lower_text, false);
  }
}

module CreateMarkerSlice(marker_angle, surface_offset, marker_text, is_upper_surface, row) {
  // Create one marker line at the given angle and surface offset
  rotate([0, 0, marker_angle])
    translate([size/2 - width - work_round_edge, 0, 0])
      rotate([90, twists * marker_angle / points, 0])  // Same as holes
        translate([0, surface_offset, 0])  // Position on upper or lower surface
          rotate([90, 0, 0])  // Rotate marker 90 degrees around X-axis to lay flat
        {
          CreateMarkerWithGap(row);
          // Add text directly on the strip surface
          translate([0, 0, (is_upper_surface ? 0.5*marker_height : -0.5*marker_height)])
            rotate([0,(is_upper_surface ? 1 : 0) * 180, 180])
            CreateNumberText(marker_text);
        }
}

module CreateMarkerWithGap(row) {
  // Create a marker line with a gap in the middle for numbers
  adjusted_length = marker_length + (2*square_overhang) - 2*(round_sharp_edge);
    
  gap_width = (row == 0) ? adjusted_length * 0.525 : adjusted_length * 0.15;  // 30% of marker length for the gap
  segment_length = (adjusted_length - gap_width) / 2;
  
  // Left segment
  translate([-segment_length/2 - gap_width/2, 0, 0])
    cube([segment_length, marker_width, marker_height], center=true);
  
  // Right segment
  translate([segment_length/2 + gap_width/2, 0, 0])
    cube([segment_length, marker_width, marker_height], center=true);
}

module CreateNumberText(marker_text) {
  // Create 3D text on the strip surface
  rotate([0, 0, 180])  // Keep text readable
    linear_extrude(height = marker_height)
      text(marker_text, 
           size = marker_width * 1.85,  // Scale text appropriately
           halign = "center", 
           valign = "center",
           font = "Fira Sans:style=Heavy");
}

module CribbageHoleCylinders() {
  // Calculate angle per hole to distribute evenly around the strip
  angle_per_hole = -360 / cribbage_rows;  // Changed to negative for clockwise
  
  for(row = [0:cribbage_rows-1]) {
    for(col = [0:cribbage_columns-1]) {
      // Calculate angle for this hole (same as the strip generation)
      hole_angle = row * angle_per_hole;
      
      // Calculate column offset to span the full width
      // For multiple columns, distribute evenly across the full width
      col_offset = cribbage_columns > 1 ? 
        (col / (cribbage_columns - 1) - 0.5) * (width * 1.5) : 0;
      
      // Use the same transformation sequence as MakeSlice
      rotate([0, 0, hole_angle])
        translate([size/2 - width - work_round_edge, 0, 0])
          rotate([90, twists * hole_angle / points, 0])  // Same as MakeSlice
            translate([col_offset, 0, 0])  // Move to column position (Z-axis in this coordinate system)
              rotate([90, 0, 0])  // Orient cylinder to go through the strip
                CreateHoleCylinder();
    }
  }
}

module CreateHoleCylinder() {
  // Create a cylinder long enough to go through the strip
  cylinder(d=hole_diameter, h=hole_length, center=true, $fn=12);
}



module CubeEdgeDecoration() {
  // Create a pattern of cubes to intersect the edge of the strip.
  offset = width + edge_offset - work_round_edge*0.6;
  surface_offset = 0;
    
  // Exponential distribution (adjustable clustering)
function exponential_angles(n_points, curve_factor=2) = 
    [for(i=[0:n_points-1]) 
        let(t = i/(n_points-1))
        -360 * (pow(curve_factor, t) - 1) / (curve_factor - 1)
    ];
    
  // Exponential distribution (adjustable clustering)
function reverse_exponential_angles(n_points, curve_factor=2) = 
    [for(i=[0:n_points-1]) 
        let(t = i/(n_points-1))
        -360 * (1 - (pow(curve_factor, 1-t) - 1) / (curve_factor - 1))
    ];

  
  reverse_angles = reverse_exponential_angles(360/4.5,.7);  
  angles = exponential_angles(360/4.5,.7);  
      
  union() {
      for(angle=angles) {  // Changed to go clockwise
        CreateCubeDecoration(angle, -offset, surface_offset, 50);  
    }
    for(angle=reverse_angles) {
        CreateCubeDecoration(angle, offset, surface_offset, -50);

    }
  }
}

module CreateCubeDecoration(angle, offset, surface_offset, angle_offset) {
  // Create one section of the decoration at the given angle and offset
  // surface_offset positions the groove on inner or outer surface
  rotate([0, 0, angle])
    translate([size/2 - width - work_round_edge, 0, 0])
      rotate([angle_offset, twists * angle / points, 0])
        translate([offset, surface_offset, 0])  // surface_offset should be on Y-axis, not Z-axis
          rotate([0, (angle_offset < 0) ? -90 : 90, 0])  // Orient groove to cut into the surface properly
            CreateCubeDecorationShape();
}

module CreateCubeDecorationShape() {
  // These angle work for a specific size. No idea if they're general.
  difference() {
  cylinder(h=work_round_edge*0.75, d1=work_round_edge*2.75, d2=0, center=true, $fn=4);
  
  union() {
  rotate([0,90,0])
      translate([-work_round_edge*0.20,0,0])
        cylinder(h=work_round_edge*2.75, d=work_round_edge*1.25, center=true, $fn=3);
      
  rotate([90,-30,0])
      translate([0.35,.5,0])
        cylinder(h=work_round_edge*2.75, d=work_round_edge*1.25, center=true, $fn=3);    
  }
  }
}




module Mobius()
{
  // Go around in a circle with the base shape.
  // Since the step is not a whole number,
  // the shape is going a little further than 360 degrees.
  // The overlap is no problem, and otherwise a gap could 
  // occur with certain values.
  union()
  {
    for(angle=[0:step:360])
    {
      if(enable_solid)
      {
        // A hull over everything for a solid base shape
        // creates extra unnessary calculations, but it makes
        // the script easier.
        hull()
          HullTwoSlices(angle);
      }
      else
      {
        HullTwoSlices(angle);
      }
    }

    // Fill the torus inside.
    if(enable_torus_fill)
    {
      rotate_extrude()
        translate([(size/2 - width - work_round_edge),0,0])
          circle(width);
    }
  }
}

// A hull() between two sequential slices.
module HullTwoSlices(angle)
{
  for(part=[0:points-1])
  {
    hull()
    {
      MakeSlice(part,angle);
      MakeSlice(part,angle+step);
    }
  }
}

// Make one slice.
// Maybe the word "slice" is not correct,
// since the basic shape is made with spheres.
module MakeSlice(_part,_angle)
{
  rotate([0,0,_angle])
    translate([size/2-width-work_round_edge,0,0])
      rotate([90,twists*_angle/points,0])
        MakeBasicShape(_part);
}

// The basic shape.
// I tried a flat circle first, but then
// the inside corners are sharp or the
// shape is strangly flattened.
// Using a sphere results in a visually
// better looking object.
module MakeBasicShape(p)
{
  rotate([0,0,p*360/points])
    translate([width-edge_offset,0,0])
    {
      if(enable_round_edge)
      {
        sphere(work_round_edge);
      }
      else
      {
        // The square edge has sharp corners.
        // Those sharp corners can be smoothed a little,
        // which makes it also easier to print.
        // Check that the shape does not disappear when
        // the negative offset would be too much.
        clipped_offset = min(work_round_edge/2,round_sharp_edge) - 0.001;
        linear_extrude(0.001)
          offset(clipped_offset)
            offset(-clipped_offset)
              square([work_round_edge*2,work_round_edge*2],center=true);
      }
    }
}