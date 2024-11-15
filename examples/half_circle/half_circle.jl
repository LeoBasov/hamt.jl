using HAMT

read_mesh("examples/half_circle/circle_very_fine.msh")

set_boundary("inner", DIRICHLET, 300.0)
set_boundary("outer", HEAT_FLUX, 1.0)

set_boundary("mirrow_left", HEAT_FLUX, 0.0)
set_boundary("mirrow_right", HEAT_FLUX, 0.0)

execute()

export_solution("half_circle")

finish_solver()