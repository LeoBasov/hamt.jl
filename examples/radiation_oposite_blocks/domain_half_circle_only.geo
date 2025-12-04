// Gmsh project created on Thu Dec  4 10:32:31 2025
SetFactory("OpenCASCADE");
//+
Point(1) = {2, 2.5, 0, 1.0};
//+
Point(2) = {2, 2.0, 0, 1.0};
//+
Point(3) = {2, 3, 0, 1.0};
//+
Circle(1) = {2, 1, 3};
//+
Line(2) = {3, 1};
//+
Line(3) = {1, 2};
//+
Curve Loop(1) = {1, 2, 3};
//+
Plane Surface(1) = {1};
//+
Physical Curve("circle_round", 4) = {1};
//+
Physical Curve("circle_flat", 5) = {2, 3};
//+
Physical Surface("circle", 6) = {1};
