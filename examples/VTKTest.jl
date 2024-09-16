using HAMT

gmsh_file = HAMT.read_Gmsh_file("test/test_data/ntr.msh");
mesh = HAMT.convert_Gmsh2_to_Mesh(gmsh_file);
HAMT.write_mesh(mesh)

println("DONE")