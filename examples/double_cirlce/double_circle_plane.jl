using HAMT

read_mesh("examples/double_cirlce/double_cirlce_plane.msh")

set_boundary("left", NEUMANN, 0.0)
set_boundary("right", NEUMANN, 0.0)
set_boundary("buttom", NEUMANN, 0.0)

set_boundary("top", DIRICHLET, 300.0)

set_surface("inner", "volumetric_heat_source", 100.0)

execute(CYLINDER)

export_solution("double_cirlce_plane")