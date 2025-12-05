using HAMT

read_mesh("examples/airfoil/NACA0012_small_fine.msh")

set_boundary("left", NEUMANN, -12.3100969126526)
set_boundary("right", NEUMANN, 12.3100969126526)
set_boundary("top", NEUMANN,2.170602220836629)
set_boundary("buttom", NEUMANN, -2.170602220836629)

set_boundary("airfoil", NEUMANN, 0.0)

execute()

export_solution("NACA0012")

finish_solver()