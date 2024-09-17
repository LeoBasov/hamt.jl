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

    return matrix, vector
end