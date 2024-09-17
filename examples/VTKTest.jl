using HAMT

gmsh_file = HAMT.read_Gmsh_file("test/test_data/ntr.msh");
mesh = HAMT.convert_Gmsh2_to_Mesh(gmsh_file);

HAMT.set_boundary!(mesh, "attachment", HAMT.DIRICHLET, 300.0)
HAMT.set_boundary!(mesh, "housing_top", HAMT.DIRICHLET, 300.0)
HAMT.set_boundary!(mesh, "housing_buttom", HAMT.DIRICHLET, 300.0)

HAMT.set_boundary!(mesh, "emitter_left", HAMT.DIRICHLET, 500.0)
HAMT.set_boundary!(mesh, "emitter_buttom", HAMT.DIRICHLET, 700.0)
HAMT.set_boundary!(mesh, "keeper_top", HAMT.DIRICHLET, 300.0)

HAMT.set_boundary!(mesh, "keeper_front", HAMT.DIRICHLET, 300.0)
HAMT.set_boundary!(mesh, "keeper_buttom", HAMT.DIRICHLET, 300.0)
HAMT.set_boundary!(mesh, "keeper_left", HAMT.DIRICHLET, 300.0)

solution = HAMT.solve_heat_equation(mesh)

HAMT.write_mesh(mesh, solution)

println("DONE")