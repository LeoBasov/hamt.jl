// Gmsh project created on Thu Dec  4 10:07:20 2025
SetFactory("OpenCASCADE");
//+
Point(1) = {0, 0, 0, 1.0};
//+
Point(2) = {1, 0, 0, 1.0};
//+
Point(3) = {1, 5, 0, 1.0};
//+
Point(4) = {0, 5, 0, 1.0};
//+
Line(1) = {1, 2};
//+
Line(2) = {2, 3};
//+
Line(3) = {3, 4};
//+
Line(4) = {4, 1};
//+
Curve Loop(1) = {4, 1, 2, 3};
//+
Plane Surface(1) = {1};
//+
Circle(5) = {2.0, 2.5, 0, 0.5, 0, 2*Pi};
//+
Curve Loop(2) = {5};
//+
Plane Surface(2) = {2};
//+
Physical Curve("circle", 6) = {5};
//+
Physical Curve("left", 7) = {4};
//+
Physical Curve("top", 8) = {3};
//+
Physical Curve("right", 9) = {2};
//+
Physical Curve("buttom", 10) = {1};
//+
Physical Surface("plane", 11) = {1};
//+
Physical Surface("circle", 12) = {2};
