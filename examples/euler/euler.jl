using HAMT

init()

read_mesh("examples/euler/circle_fine.msh")

set_boundary("left", NEUMANN, -9.6)
set_boundary("right", NEUMANN, 9.6)
set_boundary("top", NEUMANN, 0.0)
set_boundary("buttom", NEUMANN, 0.0)

set_boundary("cirlce", NEUMANN, 0.0)

execute()

export_solution("euler")

finish()