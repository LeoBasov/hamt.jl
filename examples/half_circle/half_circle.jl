using HAMT

read_mesh("examples/half_circle/circle.msh")

set_boundary("inner", DIRICHLET, 100.0)
set_boundary("outer", DIRICHLET, 300.0)

set_boundary("mirrow_left", NEUMANN, 0.0)
set_boundary("mirrow_right", NEUMANN, 0.0)

execute()

export_solution("half_circle")