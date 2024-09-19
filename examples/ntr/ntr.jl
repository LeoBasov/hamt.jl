using HAMT

read_mesh("test/test_data/ntr.msh")

set_boundary("attachment", DIRICHLET, 300.0)
set_boundary("housing_top", DIRICHLET, 300.0)
set_boundary("housing_buttom", DIRICHLET, 300.0)

set_boundary("emitter_left", DIRICHLET, 500.0)
set_boundary("emitter_buttom", DIRICHLET, 700.0)
set_boundary("keeper_top", DIRICHLET, 300.0)

set_boundary("keeper_front", DIRICHLET, 300.0)
set_boundary("keeper_buttom", DIRICHLET, 300.0)
set_boundary("keeper_left", DIRICHLET, 300.0)

execute()

export_solution("solution")