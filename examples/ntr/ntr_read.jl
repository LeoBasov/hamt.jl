using HAMT

read_hamt_mesh("ntr.hamt")


execute(CYLINDER)

export_solution("ntr", surface=true)

finish_solver()