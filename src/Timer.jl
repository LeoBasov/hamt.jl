mutable struct Timer
    reading_gmsh
    converting_mesh
    executing::Vector
    exporting

    Timer() = new(0.0, 0.0, [], 0.0)
end

function print_stats(name, stats)
    println(name * " stats")
    println("   elapsed time (s): " * string(stats.time))
    println("   bytes allocated:  " * string(stats.bytes))
end