using Printf

mutable struct Timer
    reading_gmsh
    converting_mesh
    connecting_LOS_cells
    executing::Vector
    exporting

    Timer() = new(0.0, 0.0, 0.0, [], 0.0)
end

function print_stats(name, stats)
    println(name * " stats")
    println("   elapsed time (s):      " * @sprintf("%10.6f", stats.time))

    mermory = stats.bytes / 1048576.0
    
    if mermory < 1000.0
        println("   memory allocated (MB): " * @sprintf("%10.6f", mermory))
    else
        println("   memory allocated (GB): " * @sprintf("%10.6f", mermory / 1024.0))
    end
end

function get_total_time(timer)
    total_time = timer.reading_gmsh.time
    total_time += timer.converting_mesh.time
    total_time += timer.connecting_LOS_cells.time
    total_time += sum([timer.executing[i].time for i in eachindex(timer.executing)])
    total_time += timer.exporting.time
end

function print_timer_evaluation(timer)
    total_time = get_total_time(timer)

    reading_mesh_time = get_stime(timer.reading_gmsh.time)
    pertotal_reading_mesh_time = get_pertotal_stime(timer.reading_gmsh.time, total_time)

    converting_mesh_time = get_stime(timer.converting_mesh.time)
    pertotal_converting_mesh_time = get_pertotal_stime(timer.converting_mesh.time, total_time)

    exportingh_time = get_stime(timer.exporting.time)
    pertotal_exporting_time = get_pertotal_stime(timer.exporting.time, total_time)

    connecting_LOS_cells_time = get_stime(timer.connecting_LOS_cells.time)
    pertotal_connecting_LOS_cells_time = get_pertotal_stime(timer.connecting_LOS_cells.time, total_time)

    min_executing_time = get_stime(minimum([timer.executing[i].time for i in eachindex(timer.executing)]))
    ave_executing_time = get_stime(sum([timer.executing[i].time for i in eachindex(timer.executing)]) / length(timer.executing))
    max_executing_time = get_stime(maximum([timer.executing[i].time for i in eachindex(timer.executing)]))

    pertotal_executing_time = get_pertotal_stime(sum([timer.executing[i].time for i in eachindex(timer.executing)]), total_time)

    println("\nMPI task timing breakdown:")
    println("Section         |  min time  |  avg time  |  max time  |%varavg| %total")
    println("-----------------------------------------------------------------------")
    println("reading gmsh    | " * reading_mesh_time * " | " * reading_mesh_time * " | " * reading_mesh_time * " |-------| " * pertotal_reading_mesh_time)
    println("converting mesh | " * converting_mesh_time * " | " * converting_mesh_time * " | " * converting_mesh_time * " |-------| " * pertotal_converting_mesh_time)
    println("connecting LOS  | " * connecting_LOS_cells_time * " | " * connecting_LOS_cells_time * " | " * connecting_LOS_cells_time * " |-------| " * pertotal_connecting_LOS_cells_time)
    println("execution       | " * min_executing_time * " | " * ave_executing_time * " | " * max_executing_time * " |-------| " * pertotal_executing_time)
    println("exporting       | " * exportingh_time * " | " * exportingh_time * " | " * exportingh_time * " |-------| " * pertotal_exporting_time)
    println("-----------------------------------------------------------------------")
    println("total wall time (s): " * @sprintf("%.6f", total_time))
    println("=======================================================================")
end

function get_stime(time)
    @sprintf("%10.6f", time)
end

function get_pertotal_stime(time, total_time)
    @sprintf("%7.4f", 100 * time / total_time)
end