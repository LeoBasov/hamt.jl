using HAMT

read_mesh("examples/radiation_oposite_blocks/domain_small_block.msh")

set_boundary("buttom_left", DIRICHLET, 300.0)
set_boundary("top_left", DIRICHLET, 300.0)

set_boundary("buttom_right", DIRICHLET, 300.00)
set_boundary("top_right", DIRICHLET, 300.0)

#set_boundary("left", DIRICHLET, 300.0)
set_boundary("left", DIRICHLET, 300.0)
set_boundary("right", RADIATION, 1.0)

set_boundary("center_left", DIRICHLET, 300.0)
set_boundary("center_right", DIRICHLET, 300.0)

#set_surface("right", "volumetric_heat_source", 100.0)

execute()

export_solution("radiation_small_blocks", surface=true)

finish_solver()