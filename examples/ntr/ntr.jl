using HAMT

read_mesh("examples/ntr/ntr.msh")

set_boundary("attachment", DIRICHLET, 300.0)
set_boundary("emitter_left", DIRICHLET, 1000.0)
set_boundary("emitter_buttom", DIRICHLET, 1000.0)

set_boundary("keeper_top", RADIATION, 1.0)
set_boundary("housing_top", RADIATION, 1.0)
set_boundary("housing_buttom", RADIATION, 1.0)
set_boundary("keeper_front", RADIATION, 1.0)
set_boundary("keeper_buttom", RADIATION, 1.0)
set_boundary("keeper_left", RADIATION, 1.0)

execute(CYLINDER)

export_solution("solution")
