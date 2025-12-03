using HAMT

read_mesh("examples/heat_source/domain.msh")

set_boundary("buttom", DIRICHLET, 300.0)
set_boundary("top", DIRICHLET, 300.0)
set_boundary("left", NEUMANN, 0.0)
set_boundary("right", NEUMANN, 0.0)

set_surface("surf", "volumetric_heat_source", 100.0)

execute()

export_solution("heat_source")

finish_solver()