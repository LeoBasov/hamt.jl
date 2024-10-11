module HAMT

export read_mesh
export set_boundary
export set_surface
export execute
export export_solution
export finish_solver

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
    timer.reading_gmsh = @timed read_Gmsh_file(file_name)
    timer.converting_mesh = @timed mesh = convert_Gmsh2_to_Mesh(timer.reading_gmsh.value)
    resize!(solution, length(mesh.nodes))
    fill!(solution, initial_temp)
    print("N nodes: " * string(length(mesh.nodes)) * "\n")
    print("N cells: " * string(length(mesh.cells)) * "\n")
    print_stats("reading gmsh", timer.reading_gmsh)
    print_stats("converting gmsh", timer.converting_mesh)
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
    new_error = 0.0
    mesh_has_radiation = has_radiation_boundary(mesh)

    if mesh_has_radiation
        println("connecting LOS cells")
        timer.connecting_LOS_cells = @timed connect_LineOfSite_cells!(mesh)
        print_stats("connecting LOS cells", timer.connecting_LOS_cells)
    end

    println("excuting")
    while error > max_error
        push!(timer.executing, @timed new_error = solve_heat_equation!(solution, mesh, coord_system))
        print_stats("execution", timer.executing[end])
        if !mesh_has_radiation
            break
        elseif new_error >= error
            println("   error " * string(new_error))
            break
        end
        error = new_error
        println("   error " * string(new_error))
    end
    return nothing
end

function export_solution(file_name::String; surface::Bool = false)
    global mesh
    global solution
    println("exporting")
    timer.exporting = @timed write_vtk(file_name, mesh, solution, surface)
    print_stats("export", timer.exporting)
    return nothing
end

function finish_solver()
    global Timer
    print_timer_evaluation(timer)
end

end # module HAMT
