using HAMT

read_mesh("examples/euler/circle.msh")

set_boundary("top", NEUMANN, 10.0)
set_boundary("right", DIRICHLET, 10.0)
set_boundary("top", NEUMANN, 0.0)
set_boundary("buttom", NEUMANN, 0.0)

set_boundary("circle", NEUMANN, 0.0)

execute()

export_solution("euler")

finish_solver()