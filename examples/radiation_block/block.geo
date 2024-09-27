// Gmsh project created on Fri Sep 27 11:03:57 2024
SetFactory("OpenCASCADE");
//+
Rectangle(1) = {-0.5, -0.5, 0, 1, 1, 0};
//+
Physical Curve("sides", 5) = {4, 2};
//+
Physical Curve("buttom", 6) = {1};
//+
Physical Curve("top", 7) = {3};
//+
Physical Surface("surf", 8) = {1};
