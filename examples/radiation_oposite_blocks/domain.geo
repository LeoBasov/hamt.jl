// Gmsh project created on Thu Dec  4 09:36:49 2025
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
Point(5) = {1.5, 0, 0, 1.0};
//+
Point(6) = {2.5, 0, 0, 1.0};
//+
Point(7) = {2.5, 5, 0, 1.0};
//+
Point(8) = {1.5, 5, 0, 1.0};
//+
Line(1) = {1, 2};
//+
Line(2) = {2, 3};
//+
Line(3) = {3, 4};
//+
Line(4) = {4, 1};
//+
Line(5) = {5, 6};
//+
Line(6) = {6, 7};
//+
Line(7) = {7, 8};
//+
Line(8) = {8, 5};
//+
Curve Loop(1) = {4, 1, 2, 3};
//+
Plane Surface(1) = {1};
//+
Curve Loop(2) = {8, 5, 6, 7};
//+
Plane Surface(2) = {2};
//+
Physical Curve("left", 9) = {4};
//+
Physical Curve("center_left", 10) = {2};
//+
Physical Curve("center_right", 11) = {8};
//+
Physical Curve("right", 12) = {6};
//+
Physical Curve("top_left", 13) = {3};
//+
Physical Curve("top_right", 14) = {7};
//+
Physical Curve("buttom_left", 15) = {1};
//+
Physical Curve("buttom_right", 16) = {5};
//+
Physical Surface("left", 17) = {1};
//+
Physical Surface("right", 18) = {2};
