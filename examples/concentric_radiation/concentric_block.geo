// Gmsh project created on Fri Oct 25 10:55:11 2024
SetFactory("OpenCASCADE");//+
Circle(1) = {0, 0, 0, 0.25, 0, 2*Pi};
//+
Point(2) = {-0.5, -0.25, -0, 1.0};
//+
Point(3) = {0.5, -0.25, -0, 1.0};
//+
Point(4) = {0.5, 0.25, -0, 1.0};
//+
Point(5) = {-0.5, 0.25, -0, 1.0};
//+
Point(6) = {-1, -0.5, -0, 1.0};
//+
Point(7) = {1, -0.5, -0, 1.0};
//+
Point(8) = {1, 0.5, -0, 1.0};
//+
Point(9) = {-1, 0.5, -0, 1.0};
//+
Line(2) = {2, 3};
//+
Line(3) = {3, 4};
//+
Line(4) = {4, 5};
//+
Line(5) = {5, 2};
//+
Line(6) = {6, 7};
//+
Line(7) = {7, 8};
//+
Line(8) = {8, 9};
//+
Line(9) = {9, 6};
//+
Curve Loop(1) = {1};
//+
Plane Surface(1) = {1};
//+
Curve Loop(2) = {4, 5, 2, 3};
//+
Curve Loop(3) = {8, 9, 6, 7};
//+
Plane Surface(2) = {2, 3};
//+
Physical Curve("circle", 10) = {1};
//+
Physical Curve("inner", 11) = {4, 5, 2, 3};
//+
Physical Curve("outer", 12) = {6, 7, 8, 9};
//+
Physical Surface("circle_surf", 13) = {1};
//+
Physical Surface("plane_surf", 14) = {2};
