//+
Point(1) = {-0.1, 0, 0, 1.0};
//+
Point(2) = {0.1, 0, 0, 1.0};
//+
Point(3) = {0.1, 0.5, 0, 1.0};
//+
Point(4) = {0.1, 1, 0, 1.0};
//+
Point(5) = {-0.1, 1, 0, 1.0};
//+
Point(6) = {-0.1, 0.5, 0, 1.0};
//+
Line(1) = {1, 2};
//+
Line(2) = {2, 3};
//+
Line(3) = {3, 6};
//+
Line(4) = {6, 1};
//+
Line(5) = {3, 4};
//+
Line(6) = {4, 5};
//+
Line(7) = {5, 6};
//+
Curve Loop(1) = {4, 1, 2, 3};
//+
Plane Surface(1) = {1};
//+
Curve Loop(2) = {5, 6, 7, -3};
//+
Plane Surface(2) = {2};
//+
Physical Surface("inner", 8) = {1};
//+
Physical Surface("outer", 9) = {2};
//+
Physical Curve("buttom", 10) = {1};
//+
Physical Curve("right", 11) = {2, 5};
//+
Physical Curve("top", 12) = {6};
//+
Physical Curve("left", 13) = {7, 4};
