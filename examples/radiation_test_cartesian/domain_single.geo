// Gmsh project created on Wed Dec 03 08:03:27 2025
SetFactory("OpenCASCADE");
//+
Point(1) = {0, 0, 0, 1.0};
//+
Point(2) = {3, 0, 0, 1.0};
//+
Point(3) = {3, 1, 0, 1.0};
//+
Point(4) = {0, 1, 0, 1.0};
//+
Line(1) = {1, 2};
//+
Line(2) = {2, 3};
//+
Line(3) = {3, 4};
//+
Line(4) = {4, 1};
//+
Curve Loop(1) = {3, 4, 1, 2};
//+
Plane Surface(1) = {1};
//+
Point(5) = {0.5, 1.5, 0, 1.0};
//+
Point(6) = {0.75, 1.5, 0, 1.0};
//+
Point(7) = {0.25, 1.5, 0, 1.0};
//+
Circle(7) = {6, 5, 7};
//+
Circle(8) = {7, 5, 6};
//+
Curve Loop(2) = {8, 7};
//+
Plane Surface(2) = {2};
//+
//+
Physical Curve("buttom", 9) = {1};
//+
Physical Curve("right", 10) = {2};
//+
Physical Curve("top", 11) = {3};
//+
Physical Curve("left", 12) = {4};
//+
Physical Curve("circle_left", 13) = {8, 7};
//+
Physical Surface("circle_left_surf", 16) = {2};
//+
Physical Surface("surf", 17) = {1};
