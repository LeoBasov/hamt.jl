using HAMT

read_mesh("examples/radiation_oposite_blocks/domain.msh")

set_boundary("buttom_left", RADIATION, 1.0)
set_boundary("top_left", RADIATION, 1.0)

set_boundary("buttom_right", RADIATION, 1.0)
set_boundary("top_right", RADIATION, 1.0)

#set_boundary("left", DIRICHLET, 300.0)
set_boundary("left", RADIATION, 1.0)
set_boundary("right", RADIATION, 1.0)

set_boundary("center_left", RADIATION, 1.0)
set_boundary("center_right", RADIATION, 1.0)

set_surface("right", "volumetric_heat_source", 100.0)

execute()

export_solution("radiation_oposite_blocks", surface=true)

finish_solver()