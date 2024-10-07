using HAMT

read_mesh("examples/visible_cells/domain_very_fine.msh")

set_boundary("outer", DIRICHLET, 300.0)
set_boundary("circle", DIRICHLET, 1000.0)
set_boundary("circle_arc_rest", DIRICHLET, 1000.0)

set_boundary("circle_arc_left", RADIATION, 1.0)

execute()

export_solution("visible_cells", surface=true)

finish_solver()