mutable struct Timer
    reading_gmsh::Float64
    reading_mesh::Float64
    executing::Float64
    exporting::Float64

    Timer() = new(0.0, 0.0, 0.0, 0.0)
end

function print_stats(name, stats)
    println(name * " stats")
    println("   elapsed time (s): " * string(stats.time))
    println("   bytes allocated:  " * string(stats.bytes))
end