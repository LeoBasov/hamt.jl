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

function read_mesh(file_name)
    gmsh_file = read_Gmsh_file(file_name)
    println("started reading mesh")
    @time global mesh = convert_Gmsh2_to_Mesh(gmsh_file)
    println("finished reading mesh")
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
    error = 1.0
    mesh_has_radiation = has_radiation_boundary(mesh)
    println("started excution")
    while error > max_error
        @time error = solve_heat_equation!(solution, mesh, coord_system)
        if !mesh_has_radiation
            break
        end
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
