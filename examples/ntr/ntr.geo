SetFactory("OpenCASCADE");

dx = 0.0001;
N = 3;

// Housing
Point(1) = {0.0, 50*dx, 0.0};
Point(2) = {100*dx, 50*dx, 0.0};
Point(3) = {100*dx, 60*dx, 0.0};
Point(4) = {0.0, 60*dx, 0.0};
Point(6) = {400*dx, 50*dx, 0.0};
Point(7) = {400*dx, 60*dx, 0.0};

// Emitter
Point(9) = {100*dx, 20*dx, 0.0};
Point(10) = {400*dx, 20*dx, 0.0};

// Orifice
Point(14) = {410*dx, 50*dx, 0.0};
Point(15) = {410*dx, 60*dx, 0.0};
Point(18) = {410*dx, 20*dx, 0.0};
Point(21) = {400*dx, 10*dx, 0.0};
Point(22) = {410*dx, 10*dx, 0.0};

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};
Line(5) = {2, 6};
Line(6) = {6, 7};
Line(7) = {7, 3};
Line(8) = {6, 14};
Line(9) = {14, 15};
Line(10) = {15, 7};
Line(11) = {9, 10};
Line(12) = {10, 6};
Line(13) = {2, 9};
Line(14) = {10, 18};
Line(15) = {18, 14};
Line(16) = {21, 22};
Line(17) = {22, 18};
Line(18) = {10, 21};


Curve Loop(1) = {1, 2, 3, 4};
Plane Surface(1) = {1};

Curve Loop(2) = {5, 6, 7, -2};
Plane Surface(2) = {2};

Curve Loop(3) = {11, 12, -5, 13};
Plane Surface(3) = {3};

Curve Loop(4) = {9, 10, -6, 8};
Plane Surface(4) = {4};

Curve Loop(5) = {14, 15, -8, -12};
Plane Surface(5) = {5};

Curve Loop(6) = {18, 16, 17, -14};
Plane Surface(6) = {6};

Physical Surface("emiter") = {3};
Physical Surface("housing") = {1, 2};
Physical Surface("keeper") = {4, 5, 6};

Physical Curve("attachment") = {4};
Physical Curve("housing_top") = {3, 7};
Physical Curve("housing_buttom") = {1};
Physical Curve("emitter_left") = {13};
Physical Curve("emitter_buttom") = {11};
Physical Curve("keeper_top") = {10};
Physical Curve("keeper_front") = {9, 15, 17};
Physical Curve("keeper_buttom") = {16};
Physical Curve("keeper_left") = {18};

