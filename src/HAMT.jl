module HAMT

export read_mesh
export set_boundary
export execute
export export_solution

export DIRICHLET, DIRICHLET, RADIATION, HEAT_FLUX

include("Mesh.jl")
include("Writer.jl")
include("Solver.jl")

mesh = Mesh()
solution::Vector{Float64} = []

function read_mesh(file_name)
    gmsh_file = read_Gmsh_file(file_name)
    global mesh = convert_Gmsh2_to_Mesh(gmsh_file)
    print("mesh\n")
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

function execute()
    global mesh
    global solution
    solution = solve_heat_equation(mesh)
    return nothing
end

function export_solution(file_name)
    global mesh
    global solution
    write_mesh(file_name, mesh, solution)
    return nothing
end

end # module HAMT
