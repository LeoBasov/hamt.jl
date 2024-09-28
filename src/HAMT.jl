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

mesh = Mesh()
solution::Vector{Float64} = []
max_error = 1e-12
initial_temp = 300.0

function read_mesh(file_name)
    global mesh
    global solution
    global initial_temp
    println("started reading mesh")
    @time gmsh_file = read_Gmsh_file(file_name)
    println("started reading mesh")
    println("started converting mesh")
    @time mesh = convert_Gmsh2_to_Mesh(gmsh_file)
    resize!(solution, length(mesh.nodes))
    fill!(solution, initial_temp)
    println("finished converting mesh")
    print("N nodes: " * string(length(mesh.nodes)) * "\n")
    print("N cells: " * string(length(mesh.cells)) * "\n")
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
    println("started excution")
    while error > max_error
        @time new_error = solve_heat_equation!(solution, mesh, coord_system)
        if !mesh_has_radiation
            break
        elseif new_error >= error
            println("error " * string(new_error))
            break
        end
        error = new_error
        println("error " * string(error))
    end
    println("finished excution")
    return nothing
end

function export_solution(file_name)
    global mesh
    global solution
    println("started export")
    @time write_mesh(file_name, mesh, solution)
    println("finished export")
    return nothing
end

end # module HAMT
