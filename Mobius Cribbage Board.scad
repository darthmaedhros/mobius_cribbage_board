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
hole_diameter = 3.2; // [0.5:0.1:10.0]

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

/* [Marker and Label Settings] */

// Enable markers every N holes
marker_interval = 5; // [1:10]

// Width of marker lines (how wide the line is)
marker_width = 1.7; // [0.2:0.1:2.0]

// Height of marker lines (how tall/thick they are)
marker_height = 1.2; // [0.1:0.1:5.0]

// Depth of marker lines (how far they are inset into the surface)
marker_depth = 0; // [0.0:0.05:0.5]

// Length of marker lines (should span all columns plus extra)
marker_length = width*2; // [15:40]

// Label height in center of marker
label_height = 4.1; // [0.1:.1:10]
vertical_overlap = 1.8; // [0.1:.1:10]
label_width = 17.2; // [0.1:.1:20]
horizontal_overlap = 1.25; // [0.1:.1:10]

top_intersection_diameter = 2.5*label_width; // [0.1:.1:10]
side_intersection_diameter = 5.0; // [0.1:.1:10]
corner_intersection_diameter = 4.5; // [0.1:.1:10]
corner_offset = 1; // [0.1:0.1:10]


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
  // Calculate angle per total segment of 5 holes
  num_segments = cribbage_rows / marker_interval;
  angle_per_segment = -360 / num_segments;

  for(segment = [0:num_segments-1]) {
      marker_angle = segment*angle_per_segment;
          
    // Upper surface: normal numbering (0, 5, 10, 15, etc.)
    upper_text = (segment == 0) ? "START/FINISH" :
                 str(segment*marker_interval);
    
    // Lower surface: offset numbering (60, 5, 10, 15, etc.)
    // For cribbage, the opposite side typically shows 60 points ahead
    lower_row = (segment*marker_interval) % 60;  // Changed: offset by 30 and wrap at 60
    lower_text = (lower_row == 30) ? "S" :  // S at 30 on the offset side
                 str(lower_row + 60);
    
    // Create upper surface marker with gap
    CreateMarkerSlice(marker_angle, work_round_edge - marker_depth, upper_text, true, segment*marker_interval);
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
            union() {
//          CreateMarkerWithGap(row);
          CreateFancyMarker(row);
          // Add text directly on the strip surface
          translate([0, 0, (is_upper_surface ? -.33*marker_height : 0.33*marker_height)])
            rotate([0,(is_upper_surface ? 1 : 0) * 180, 180])
            CreateNumberText(marker_text);
            }
        }
}


module CreateFancyMarker(row) {
    adjusted_length = marker_length + (2*square_overhang) - 2*(round_sharp_edge);
    
    union() {
    hull() {
        cylinder(h=marker_height, d=4*marker_width, center=true, $fn=12);

        translate([-adjusted_length/2 + marker_width/2,0,0]) sphere(d=marker_height, $fn=12);

        translate([adjusted_length/2 - marker_width/2,0,0]) sphere(d=marker_height, $fn=12);
    }
    label_shape(row);
}
}


module label_shape(row) {
    if(row == 0) {
    rotate([0,0,90])
    difference() {
        hull() {
            translate([0,label_width/2,0])
            cylinder(h=marker_height+0.01, d = label_height + 2*vertical_overlap, $fn=24, center=true);
            
            translate([0,-label_width/2,0])
            cylinder(h=marker_height+0.01, d = label_height + 2*vertical_overlap, $fn=24, center=true);    
        }
        
        // Vertical
        translate([-label_height/2 - top_intersection_diameter/2,0,0])
        cylinder(h=marker_height+0.1, d=top_intersection_diameter, $fn=64, center=true);

        translate([label_height/2 + top_intersection_diameter/2,0,0])
        cylinder(h=marker_height+0.1, d=top_intersection_diameter, $fn=64, center=true);
        
        // Horizontal
        translate([0,(label_width + side_intersection_diameter + label_height + 2*vertical_overlap)/2 - horizontal_overlap, 0])
        cylinder(h=marker_height + 0.1, d = side_intersection_diameter, $fn=24, center=true);
        
        translate([0,-(label_width + side_intersection_diameter + label_height + 2*vertical_overlap)/2 + horizontal_overlap, 0])
        cylinder(h=marker_height + 0.1, d = side_intersection_diameter, $fn=24, center=true);
        
        // Corner
        // Find angle to intersection with edge circles.
        
        // Parameters for the circles
        circle_A_center = [0, label_width/2];
        circle_A_radius = (label_height + 2*vertical_overlap)/2;

        circle_B_radius = side_intersection_diameter/2;
        circle_B_offset = [0, circle_A_radius + circle_B_radius - horizontal_overlap];

        circle_C_radius = top_intersection_diameter/2;
        circle_C_offset = [circle_A_radius + circle_C_radius - vertical_overlap, -label_width/2];
        
        // Calculate circle centers
        circle_B_center = circle_A_center + circle_B_offset;
        circle_C_center = circle_A_center + circle_C_offset;

        phi = analyze_circle_intersections(circle_A_center, circle_A_radius, circle_A_center + circle_B_offset, circle_B_radius, circle_A_center + circle_C_offset, circle_C_radius)[6][1];
        
        
            
        translate([0,label_width/2,0])
        translate([-cos(phi)*(label_height+2*vertical_overlap)/2 - corner_offset,sin(phi)*(label_height+2*vertical_overlap)/2  + 0.6*corner_offset, 0])
        cylinder(h=marker_height + 0.1, d = corner_intersection_diameter, $fn=24, center=true);

        translate([0,label_width/2,0])
        translate([cos(phi)*(label_height+2*vertical_overlap)/2 + corner_offset,sin(phi)*(label_height+2*vertical_overlap)/2 + 0.6*corner_offset, 0])
        cylinder(h=marker_height + 0.1, d = corner_intersection_diameter, $fn=24, center=true);

        translate([0,-label_width/2,0])
        translate([cos(phi)*(label_height+2*vertical_overlap)/2 + corner_offset,-sin(phi)*(label_height+2*vertical_overlap)/2 - 0.6*corner_offset, 0])
        cylinder(h=marker_height + 0.1, d = corner_intersection_diameter, $fn=24, center=true);

        translate([0,-label_width/2,0])
        translate([-cos(phi)*(label_height+2*vertical_overlap)/2 - corner_offset,-sin(phi)*(label_height+2*vertical_overlap)/2 - 0.6*corner_offset, 0])
        cylinder(h=marker_height + 0.1, d = corner_intersection_diameter, $fn=24, center=true);
    }
}
}


module CreateNumberText(marker_text) {
  // Create 3D text on the strip surface
  rotate([0, 0, 180])  // Keep text readable
    translate([0,0,-0.5*marker_height])
    linear_extrude(height = marker_height+.02)
      text(marker_text, 
           size = marker_width * 1.3,  // Scale text appropriately
           halign = "center", 
           valign = "center",
           font = "Roboto Slab:style=Heavy");
}

module CribbageHoleCylinders() {
  // Calculate angle per total segment of 5 holes
  num_segments = cribbage_rows / marker_interval;
  angle_per_segment = -360 / num_segments;

  marker_margin_angle = -4;

  angle_per_hole = (angle_per_segment - 2*marker_margin_angle) / (marker_interval-1); 
   
  for(segment = [0:num_segments-1]) {
      segment_angle = segment * angle_per_segment;
      
    for(row = [0:marker_interval-1]) {
        for(col = [0:cribbage_columns-1]) {
            hole_angle = segment_angle + marker_margin_angle + (row * angle_per_hole);
            
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

  
  reverse_angles = reverse_exponential_angles(360/4,.60);  
  angles = exponential_angles(360/4,.60);  
      
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



// Helper functions for generating marker labels
// Function to calculate distance between two points
function distance(p1, p2) = sqrt(pow(p2[0] - p1[0], 2) + pow(p2[1] - p1[1], 2));

// Function to find intersection points between two circles
function circle_intersections(c1, r1, c2, r2) = 
    let(
        d = distance(c1, c2),
        // Check if circles intersect
        intersect = (d <= r1 + r2) && (d >= abs(r1 - r2)) && (d > 0)
    )
    intersect ? 
        let(
            a = (pow(r1, 2) - pow(r2, 2) + pow(d, 2)) / (2 * d),
            h = sqrt(pow(r1, 2) - pow(a, 2)),
            p0_x = c1[0] + a * (c2[0] - c1[0]) / d,
            p0_y = c1[1] + a * (c2[1] - c1[1]) / d,
            p1_x = p0_x + h * (c2[1] - c1[1]) / d,
            p1_y = p0_y - h * (c2[0] - c1[0]) / d,
            p2_x = p0_x - h * (c2[1] - c1[1]) / d,
            p2_y = p0_y + h * (c2[0] - c1[0]) / d
        )
        [[p1_x, p1_y], [p2_x, p2_y]]
    : [];

// Function to calculate angle from center to a point
function point_angle_from_center(center, point) = atan2(point[1] - center[1], point[0] - center[0]);

// Function to calculate angular distance between two angles (handles wrap-around)
function angular_distance(angle1, angle2) = 
    let(diff = abs(angle2 - angle1))
    diff > 180 ? 360 - diff : diff;

// Function to find closest pair of points based on angular distance from center
function find_closest_pair_angular(center_A, points_set1, points_set2) =
    let(
        angles1 = [for (point = points_set1) point_angle_from_center(center_A, point)],
        angles2 = [for (point = points_set2) point_angle_from_center(center_A, point)],
        angular_distances = [for (i = [0:len(points_set1)-1])
                               for (j = [0:len(points_set2)-1])
                                   [angular_distance(angles1[i], angles2[j]), i, j]]
    )
    len(angular_distances) > 0 ?
        let(min_dist_data = angular_distances[search(min(angular_distances), angular_distances)[0]])
        [points_set1[min_dist_data[1]], points_set2[min_dist_data[2]], min_dist_data[0]]
    : [];

// Main function to analyze circle intersections
function analyze_circle_intersections(center_A, radius_A, center_B, radius_B, center_C, radius_C) =
    let(
        // Calculate intersections
        intersections_AB = circle_intersections(center_A, radius_A, center_B, radius_B),
        intersections_AC = circle_intersections(center_A, radius_A, center_C, radius_C),
        
        // Find closest intersection points between B∩A and C∩A based on angular distance
        closest_pair_data = (len(intersections_AB) >= 1 && len(intersections_AC) >= 1) ?
            find_closest_pair_angular(center_A, intersections_AB, intersections_AC) : [],
            
        closest_point_B = len(closest_pair_data) == 3 ? closest_pair_data[0] : undef,
        closest_point_C = len(closest_pair_data) == 3 ? closest_pair_data[1] : undef,
        
        // Calculate angles of closest intersection points from center A
        angle_B_from_A = (closest_point_B != undef) ? 
            point_angle_from_center(center_A, closest_point_B) : undef,
        angle_C_from_A = (closest_point_C != undef) ? 
            point_angle_from_center(center_A, closest_point_C) : undef,
            
        // Calculate midpoint angle between the closest intersection points
        midpoint_angle_value = (angle_B_from_A != undef && angle_C_from_A != undef) ?
            (angle_B_from_A + angle_C_from_A)/2 : undef
    )
    [
        ["intersections_AB", intersections_AB],
        ["intersections_AC", intersections_AC],
        ["closest_point_B", closest_point_B],
        ["closest_point_C", closest_point_C],
        ["angle_B_from_A", angle_B_from_A],
        ["angle_C_from_A", angle_C_from_A],
        ["midpoint_angle", midpoint_angle_value],
    ];
