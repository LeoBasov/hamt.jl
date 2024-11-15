// Gmsh project created on Mon Oct  7 11:59:56 2024
SetFactory("OpenCASCADE");//+
Point(1) = {-1, -1, 0, 1.0};
//+
Point(2) = {1, -1, 0, 1.0};
//+
Point(3) = {1, 1, 0, 1.0};
//+
Point(4) = {-1, 1, 0, 1.0};
//+//+
Line(1) = {1, 2};
//+
Line(2) = {2, 3};
//+
Line(3) = {3, 4};
//+
Line(4) = {4, 1};
//+
Circle(5) = {0.5, 0.5, 0, .1, 0, 2*Pi};
//+
Point(6) = {-0.5, -0.5, 0, 1.0};
//+
Point(7) = {-0.6, -0.5, 0, 1.0};
//+
Point(8) = {-0.7, -0.5, 0, 1.0};
//+
Circle(6) = {8, 7, 6};
//+
Point(9) = {-0.6, -0.4, 0, 1.0};
//+
Circle(6) = {6, 7, 9};
//+
Circle(7) = {9, 7, 6};
//+
Point(10) = {-0.6, -0.6, 0, 1.0};
//+
Circle(8) = {9, 7, 8};
//+
Circle(9) = {7, 8, 10};
//+
Circle(9) = {8, 7, 10};
//+
Circle(10) = {10, 7, 6};
//+
Curve Loop(1) = {3, 4, 1, 2};
//+
Curve Loop(2) = {5};
//+
Curve Loop(3) = {6, 8, 9, 10};
//+
Plane Surface(1) = {1, 2, 3};
//+
Physical Surface("surf", 11) = {1};
//+
Physical Curve("outer", 12) = {3, 4, 1, 2};
//+
Physical Curve("circle", 13) = {5};
//+
Physical Curve("circle_arc_left", 14) = {9};
//+
Physical Curve("circle_arc_rest", 15) = {8, 6, 10};
