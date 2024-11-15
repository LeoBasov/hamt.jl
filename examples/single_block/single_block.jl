using HAMT

read_mesh("examples/single_block/block_single_triangular.msh")

set_boundary("buttom", DIRICHLET, 100.0)
set_boundary("top", DIRICHLET, 300.0)
set_boundary("left", NEUMANN, 0.0)
set_boundary("right", NEUMANN, 0.0)

execute()

export_solution("block_single_triangular")

finish_solver()