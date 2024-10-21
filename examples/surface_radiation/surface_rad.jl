using HAMT

read_mesh("examples/surface_radiation/object_fine.msh")

set_boundary("left", DIRICHLET, 1000.0)
set_boundary("top", RADIATION, 1.0, background_radiaton_only = true)
set_boundary("right", RADIATION, 1.0, background_radiaton_only = true)
set_boundary("buttom", RADIATION, 1.0)
set_boundary("angle_up", RADIATION, 1.0)
set_boundary("angle_down", RADIATION, 1.0)

execute()

export_solution("surface_rad", surface=true)

finish_solver()