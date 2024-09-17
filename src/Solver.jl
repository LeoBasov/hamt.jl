using LinearSolve

function solve_heat_equation(mesh)
    matrix, vector = convert_triangular_mesh(mesh)
    problem = LinearProblem(matrix, vector)
    sol = solve(problem)
    return sol.u
end

function convert_triangular_mesh(mesh)
    matrix::Matrix{Float64} = zeros(length(mesh.nodes), length(mesh.nodes))
    vector::Vector{Float64} = zeros(length(mesh.nodes))

    for node_id=1:length(mesh.nodes)
        if length(mesh.nodes[node_id].boundaries) > 0
            conver_boundaries!(matrix, vector, mesh, node_id)
        else
            convert_center!(matrix, vector, mesh, node_id)
        end
    end

    return matrix, vector
end

function convert_center!(matrix, vector, mesh, node_id)
end

function conver_boundaries!(matrix, vector, mesh, node_id)
    #TODO
    matrix[node_id, node_id] = 1.0
    vector[node_id] = 1.0
end