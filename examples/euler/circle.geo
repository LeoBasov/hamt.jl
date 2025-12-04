// Gmsh project created on Thu Dec  4 14:39:56 2025
SetFactory("OpenCASCADE");
//+
Point(1) = {0, 0, 0, 1.0};
//+
Point(2) = {1, 0, 0, 1.0};
//+
Point(3) = {1, 1, 0, 1.0};
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
Circle(5) = {0.5, 0.5, 0, 0.1, 0, 2*Pi};
//+
Curve Loop(1) = {4, 1, 2, 3};
//+
Curve Loop(2) = {5};
//+
Plane Surface(1) = {1, 2};
//+
Physical Curve("left", 6) = {4};
//+
Physical Curve("buttom", 7) = {1};
//+
Physical Curve("right", 8) = {2};
//+
Physical Curve("top", 9) = {3};
//+
Physical Curve("cirlce", 10) = {5};
//+
Physical Surface("surf", 11) = {1};
