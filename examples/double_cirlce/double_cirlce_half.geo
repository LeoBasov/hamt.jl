// Gmsh project created on Sat Sep 21 20:42:17 2024
SetFactory("OpenCASCADE");
//+
Point(1) = {-1, 0, 0, 1.0};
//+
Point(2) = {-0.5, 0, 0, 1.0};
//+
Point(3) = {0, 0, 0, 1.0};
//+
Point(4) = {0.5, 0, 0, 1.0};
//+
Point(5) = {1, 0, 0, 1.0};
//+
Circle(1) = {2, 3, 4};
//+
Circle(2) = {1, 3, 5};//+
Line(3) = {1, 2};
//+
Line(4) = {2, 3};
//+
Line(5) = {3, 4};
//+
Line(6) = {4, 5};
//+
Curve Loop(1) = {1, -5, -4};
//+
Plane Surface(1) = {1};
//+
Curve Loop(2) = {2, -6, -1, -3};
//+
Plane Surface(2) = {2};
//+
Physical Curve("boundary", 7) = {2};
//+
Physical Curve("symmetry", 8) = {3, 4, 5, 6};
//+
Physical Surface("inner", 9) = {1};
//+
Physical Surface("outer", 10) = {2};
