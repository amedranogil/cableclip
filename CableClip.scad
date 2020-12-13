cableD=20;
wall=1.6;
height=19;
baseExtra=3;
hole=5;
clip_baseRatio=1/3;
topAngle=45;
bottomAngle=40;
openAngle= 35;
Nhooks=3;
tolerance=0.4;
module base(){
    width=cableD;
    baseH=width/2+baseExtra;
    difference(){
        union(){
            cylinder(d=width,h=height,$fn=6);
            translate([-width/2,0,0]) cube([width,baseH,height]);
        }
        translate([0,0,-1])scale([1,1,2]) {
            cylinder(d=width-wall*1,h=height,$fn=6);
            translate([0,-cableD*clip_baseRatio,0]) cylinder(d=cableD,h=height);
        }
        translate([0,0,height/2]) rotate([-90,0,0])
            cylinder(d=hole,h=baseH+wall);
            
    }
}

//base();

module sector(radius, angles, fn = 24) {
    r = radius / cos(180 / fn);
    step = -360 / fn;

    points = concat([[0, 0]],
        [for(a = [angles[0] : step : angles[1] - 360]) 
            [r * cos(a), r * sin(a)]
        ],
        [[r * cos(angles[1]), r * sin(angles[1])]]
    );

    difference() {
        circle(radius, $fn = fn);
        polygon(points);
    }
}


//!linear_extrude(height) sector (cableD/2,[60,120]);

module clipbase(d,h,w,a){
    difference(){
        cylinder(d=d,h=h);
        translate([0,0,-1])
            cylinder(d=d-w*2,h=h+2);
//        translate([-(hole+w*2)/2,0,-1]) cube([hole+w*2,d+w,h+2]);
    }
    for (r=a*[-1,1])
        rotate([0,0,-90+r])
            translate([d/2-0.2,-w/2,0]) cube([2*w,w,h]);
}
//translate([0,-cableD*clip_baseRatio,0])
//clipbase(cableD,height,wall,topAngle);

module Mclip(){
    difference(){
        clipbase(cableD,height,wall,topAngle);
        translate([0,0,-1])linear_extrude(height+2) 
            sector (cableD/2+3*wall,[90+bottomAngle/2, -90+topAngle/2, ]);
    }
    rotate([0,0,+topAngle/2])translate([-wall,-cableD/2+0.1,0]) cylinder(d=wall*2,h=height,$fn=3);
}

module Fclip(){
    dd=tolerance;
    n=Nhooks;
    anglediff=asin((4*wall)/cableD);
    intersection(){
        clipbase(cableD,height,wall,topAngle);
        translate([0,0,-1])linear_extrude(height+2) 
            sector (cableD/2+3*wall,[90-bottomAngle/2, -90+topAngle/2+2*asin(dd/cableD), ]);
    }
    difference(){
        hull(){
        linear_extrude(height) 
            sector (cableD/2+2*wall,[-90+topAngle*2/3, -90-(n-0.5)*anglediff, ],40);
            linear_extrude(height) 
            sector (cableD/2,[-90+topAngle, -90-(n-0.5)*anglediff, ],40);
        }
        translate([0,0,-1])cylinder(d=cableD,h=height+2);
        for (i=[0:n])
        rotate([0,0,+topAngle/2-i*anglediff])translate([-wall-dd,-cableD/2+0.1,-1]) cylinder(d=wall*2+dd,h=height+2,$fn=3);
    }
}

module transrot(trans,rot){
    translate(trans) 
    rotate(rot) 
    translate(-trans) 
    children();
}
//translate([-(cableD/2)*sin(60),(cableD/2)*cos(60),0]) cylinder(d=0.11,h=20);

transrot([-(cableD/2)*sin(60),(cableD/2)*cos(60),0],[0,0,-openAngle]) 
    Mclip();
transrot([(cableD/2)*sin(60),(cableD/2)*cos(60),0],[0,0,openAngle/2]) 
    Fclip();
translate([0,cableD*clip_baseRatio-wall/2,0])
base();