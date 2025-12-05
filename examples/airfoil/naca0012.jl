using HAMT

read_mesh("examples/airfoil/NACA0012_semi_fine.msh")

set_boundary("left", NEUMANN, -12.5)
set_boundary("right", NEUMANN, 12.5)
set_boundary("top", NEUMANN,0 )
set_boundary("buttom", NEUMANN, 0)

set_boundary("airfoil", NEUMANN, 0.0)

execute()

export_solution("NACA0012")

finish_solver()