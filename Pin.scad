hole_depth = 5.5;
pin_height = 12.0;
hole_radius = 1.5;
pin_radius = 2.0;
inset_sphere_radius = pin_height - 1;
angular_separation = 10;
tolerance=0.2;

vertical_offset = pin_height/8;

difference()
{
    union() 
    {
        cylinder(h=pin_height, r=pin_radius, center=true, $fn = 50);
        translate([0,0,-pin_height/2 - hole_depth/2])
        cylinder(h=hole_depth, r=hole_radius-tolerance, center=true,$fn=50);
    }

    union() 
    {
        for (i = [0:angular_separation:360]) {
            rotate([0,0,i])
            translate([-inset_sphere_radius - hole_radius,0,vertical_offset])
            sphere(r=inset_sphere_radius,$fn=100);
            rotate([0,0,i])
            translate([-inset_sphere_radius - hole_radius,0,pin_height-2*vertical_offset])
            sphere(r=inset_sphere_radius,$fn=100);  
        }

    }
}