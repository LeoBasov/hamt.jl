//+
Point(1) = {-0.5, 0.1, 0, 1.0};
//+
Point(2) = {-0.5, 0.5, 0, 1.0};
//+
Point(3) = {1, 0.5, 0, 1.0};
//+
Point(4) = {1, 0.25, 0, 1.0};
//+
Point(5) = {0, 0.25, 0, 1.0};
//+
Point(6) = {-0.25, 0.4, 0, 1.0};
//+
Line(1) = {1, 6};
//+
Line(2) = {6, 5};
//+
Line(3) = {5, 4};
//+
Line(4) = {4, 3};
//+
Line(5) = {3, 2};
//+
Line(6) = {2, 1};
//+
Curve Loop(1) = {5, 6, 1, 2, 3, 4};
//+
Plane Surface(1) = {1};
//+
Physical Surface("surf", 7) = {1};
//+
Physical Curve("left", 8) = {6};
//+
Physical Curve("top", 9) = {5};
//+
Physical Curve("right", 10) = {4};
//+
Physical Curve("buttom", 11) = {3};
//+
Physical Curve("angle_up", 12) = {2};
//+
Physical Curve("angle_down", 13) = {1};
