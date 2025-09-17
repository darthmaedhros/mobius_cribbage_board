marker_height = 1.2; // [0.1:.1:10]
label_height = 5; // [0.1:.1:10]
vertical_overlap = 1; // [0.1:.1:10]
label_width = 10; // [0.1:.1:20]
horizontal_overlap = 1.25; // [0.1:.1:10]

top_intersection_diameter = 2.5*label_width; // [0.1:.1:10]
side_intersection_diameter = 5.0; // [0.1:.1:10]
corner_intersection_diameter = 4.5; // [0.1:.1:10]
corner_offset = 1; // [0.1:0.1:10]

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


module label_shape() {
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


// Width of the base shape that is used to make the ring.
width = 15; // [2:40]

// Length of marker lines (should span all columns plus extra)
marker_length = width*2; // [15:40]

// Width of marker lines (how wide the line is)
marker_width = 1.7; // [0.2:0.1:2.0]

// Separating the edge offsets for non-round edge case.
square_overhang = 1;

// Radius of the circle for smoothing sharp edges.
round_sharp_edge = 0.2; // [0.0:0.1:2.0]


adjusted_length = marker_length + (2*square_overhang) - 2*(round_sharp_edge);

color("Ivory")
label_shape();

color("Sienna")
hull() {
    cylinder(h=marker_height, d=4*marker_width, center=true, $fn=12);

    translate([-adjusted_length/2 + marker_width/2,0,0]) sphere(d=marker_height, $fn=12);

    translate([adjusted_length/2 - marker_width/2,0,0]) sphere(d=marker_height, $fn=12);
}

color("Sienna")
// Create 3D text on the strip surface
rotate([0, 0, 180])  // Keep text readable
translate([0,0,-0.5*marker_height])
linear_extrude(height = marker_height+.02)
  text("START/FINISH", 
       size = marker_width * 1.3,  // Scale text appropriately
       halign = "center", 
       valign = "center",
       font = "Roboto Slab:style=Bold");


