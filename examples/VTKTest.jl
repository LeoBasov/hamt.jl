using HAMT

gmsh_file = HAMT.read_Gmsh_file("test/test_data/ntr.msh");
mesh = HAMT.convert_Gmsh2_to_Mesh(gmsh_file);
solution = HAMT.solve_heat_equation(mesh)

HAMT.write_mesh(mesh, solution)

println("DONE")