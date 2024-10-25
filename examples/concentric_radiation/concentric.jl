using HAMT

read_mesh("examples/concentric_radiation/concentric.msh")

set_boundary("inner", DIRICHLET, 500.0)
set_boundary("middle", RADIATION, 1.0)
set_boundary("outer", RADIATION, 1.0, background_radiaton_only=true)

#set_surface("outer", "volumetric_heat_source", 10)

export_mesh("concentric")

execute()

export_solution("concentric")

finish_solver()