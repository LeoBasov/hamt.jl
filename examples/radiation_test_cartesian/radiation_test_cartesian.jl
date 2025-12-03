using Revise
using HAMT

read_mesh("examples/radiation_test_cartesian/domain.msh")

set_boundary("buttom", DIRICHLET, 300.0)
set_boundary("left", DIRICHLET, 300.0)

set_boundary("top", RADIATION, 1.0)
set_boundary("right", RADIATION, 1.0)
set_surface("surf", "thermal_conductivity", 100)

set_boundary("circle_right", RADIATION, 1.0)
set_boundary("circle_left", DIRICHLET, 300.0)
set_surface("circle_left_surf", "thermal_conductivity", 100)
set_surface("circle_right_surf", "thermal_conductivity", 100)

#set_surface("circle_left_surf", "volumetric_heat_source", 100.0)

execute()

export_solution("radiation_test_cartesian", surface=true)

finish_solver()