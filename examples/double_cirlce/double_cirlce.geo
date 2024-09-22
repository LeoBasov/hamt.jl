// Gmsh project created on Fri Sep 20 17:43:10 2024
SetFactory("OpenCASCADE");
//+
Circle(1) = {0, 0, 0, 0.5, 0, 2*Pi};
//+
Circle(2) = {0, 0, 0, 1, 0, 2*Pi};
//+
Curve Loop(1) = {1};
//+
Plane Surface(1) = {1};
//+
Curve Loop(2) = {2};
//+
Curve Loop(3) = {1};
//+
Plane Surface(2) = {2, 3};
//+
Physical Curve("boundary", 4) = {2};
//+
Physical Surface("inner", 5) = {1};
//+
Physical Surface("outer", 6) = {2};
