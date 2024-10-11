using HAMT

read_mesh("examples/radiation_block/block.msh")

set_boundary("buttom", DIRICHLET, 100.0)
set_boundary("top", RADIATION, 1.0)
set_boundary("sides", NEUMANN, 0.0)

execute()

export_solution("radiation_block")

finish_solver()