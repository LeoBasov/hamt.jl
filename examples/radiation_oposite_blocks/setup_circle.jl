using HAMT

read_mesh("examples/radiation_oposite_blocks/domain_circle.msh")

set_boundary("left", RADIATION, 1.0)
set_boundary("top", RADIATION, 1.0)
set_boundary("buttom", RADIATION, 1.0)
set_boundary("right", RADIATION, 1.0)

set_boundary("circle", DIRICHLET, 300.0)

#set_surface("right", "volumetric_heat_source", 100.0)

execute()

export_solution("radiation_oposite_circle", surface=true)

finish_solver()