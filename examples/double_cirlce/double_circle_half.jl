using HAMT

read_mesh("examples/double_cirlce/double_cirlce_half_fine.msh")

set_boundary("boundary", DIRICHLET, 300.0)
set_boundary("symmetry", NEUMANN, 0.0)

set_surface("inner", "volumetric_heat_source", 100.0)

execute()

export_solution("double_cirlce_half")