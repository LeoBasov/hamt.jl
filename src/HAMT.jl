module HAMT

export read_mesh
export set_boundary
export set_surface
export execute
export export_solution

export DIRICHLET, NEUMANN, RADIATION, HEAT_FLUX
export CARTESIAN, CYLINDER

include("Mesh.jl")
include("Writer.jl")
include("Solver.jl")
include("Timer.jl")

timer = Timer()
mesh = Mesh()
solution::Vector{Float64} = []
max_error = 1e-12
initial_temp = 300.0

function read_mesh(file_name)
    global mesh
    global solution
    global initial_temp
    println("reading and converting mesh")
    reading_gmsh = @timed read_Gmsh_file(file_name)
    converting_mesh = @timed mesh = convert_Gmsh2_to_Mesh(reading_gmsh.value)
    resize!(solution, length(mesh.nodes))
    fill!(solution, initial_temp)
    print("N nodes: " * string(length(mesh.nodes)) * "\n")
    print("N cells: " * string(length(mesh.cells)) * "\n")
    print_stats("reading gmsh", reading_gmsh)
    print_stats("converting gmsh", converting_mesh)
    return nothing
end

function set_boundary(name, type, value)
    global mesh
    set_boundary!(mesh, name, type, value)
    print("set boundary [" * name * "] to type [" * string(type) * "] and value [" * string(value) *"]\n")
    return nothing
end

function set_surface(name, type, value)
    global mesh
    set_surface_property!(mesh, name, type, value)
    print("set surface [" * name * "] to type [" * type * "] and value [" * string(value) *"]\n")
    return nothing
end

function execute(coord_system::CoordSystem = CARTESIAN)
    global mesh
    global solution
    global max_error
    error = Inf
    mesh_has_radiation = has_radiation_boundary(mesh)
    println("excuting")
    while error > max_error
        stats = @timed solve_heat_equation!(solution, mesh, coord_system)
        print_stats("execution", stats)
        if !mesh_has_radiation
            break
        elseif stats.value >= error
            println("error " * string(stats.value))
            break
        end
        error = stats.value
        println("error " * string(error))
    end
    return nothing
end

function export_solution(file_name)
    global mesh
    global solution
    println("exporting")
    stats = @timed write_mesh(file_name, mesh, solution)
    print_stats("export", stats)
    return nothing
end

end # module HAMT
