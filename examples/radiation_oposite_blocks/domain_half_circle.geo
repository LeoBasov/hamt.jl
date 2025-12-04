// Gmsh project created on Thu Dec  4 10:20:35 2025
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
Point(5) = {2.0, 2.0, 0, 1.0};
//+
Point(6) = {2.0, 2.5, 0, 1.0};
//+
Point(7) = {2.0, 3, 0, 1.0};
//+
Line(1) = {1, 2};
//+
Line(2) = {2, 3};
//+
Line(3) = {3, 4};
//+
Line(4) = {4, 1};
//+
Circle(5) = {5, 6, 7};
//+
Line(6) = {7, 6};
//+
Line(7) = {6, 5};
//+
Curve Loop(1) = {4, 1, 2, 3};
//+
Plane Surface(1) = {1};
//+
Curve Loop(2) = {5, 6, 7};
//+
Plane Surface(2) = {2};
//+
Physical Curve("left", 8) = {4};
//+
Physical Curve("top", 9) = {3};
//+
Physical Curve("right", 10) = {2};
//+
Physical Curve("buttom", 11) = {1};
//+
Physical Curve("circle_round", 12) = {5};
//+
Physical Curve("circle_flat", 13) = {6, 7};
//+
Physical Surface("plane", 14) = {1};
//+
Physical Surface("circle", 15) = {2};
