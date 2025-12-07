using HAMT

read_mesh("examples/half_circle/circle_very_fine.msh")

set_boundary("inner", DIRICHLET, 300.0)
set_boundary("outer", NEUMANN, 1.0)

set_boundary("mirrow_left", NEUMANN, 0.0)
set_boundary("mirrow_right", NEUMANN, 0.0)

execute()

export_solution("half_circle")

finish_solver()