using HAMT

read_mesh("examples/two_block/two_blocks.msh")

set_boundary("l_buttom", DIRICHLET, 100.0)
set_boundary("l_buttom_right", NEUMANN, 0.0)
set_boundary("l_buttom_left", NEUMANN, 0.0)

set_boundary("l_top_right", NEUMANN, 0.0)
set_boundary("l_top_left", NEUMANN, 0.0)
set_boundary("l_top", DIRICHLET, 300.0)

set_surface("top", "thermal_conductivity", 5.0)

execute()

export_solution("solution")

