// Gmsh project created on Fri Oct 25 10:50:23 2024
SetFactory("OpenCASCADE");//+
Circle(1) = {0, 0, 0, 0.5, 0, 2*Pi};
//+
Circle(2) = {0, 0, 0, 1.5, 0, 2*Pi};
//+
Circle(3) = {0, 0, 0, 2.5, 0, 2*Pi};
//+
Curve Loop(1) = {1};
//+
Plane Surface(1) = {1};
//+
Curve Loop(2) = {3};
//+
Curve Loop(3) = {3};
//+
Curve Loop(4) = {2};
//+
Plane Surface(2) = {2, 3, 4};
//+
Physical Curve("inner", 5) = {1};
//+
Physical Curve("middle", 6) = {2};
//+
Physical Curve("outer", 7) = {3};
//+
Physical Surface("inner", 8) = {1};
//+
Physical Surface("outer", 9) = {2};
