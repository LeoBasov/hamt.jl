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
    node = mesh.nodes[node_id]

    for cell_id in node.adjacent_cells
        cell = mesh.cells[cell_id]
        pos_i = findall(x -> x == node_id, cell.nodes)[1]
        pos_ip = pos_i == 3 ? 1 : pos_i + 1
        pos_im = pos_i == 1 ? 3 : pos_i - 1
        node_id_ip = cell.nodes[pos_ip]
        node_id_im = cell.nodes[pos_im]
        node_pos_i = node.position
        node_pos_ip = mesh.nodes[node_id_ip].position
        node_pos_im = mesh.nodes[node_id_im].position

        dx10 = node_pos_ip[1] - node_pos_i[1]
        dx20 = node_pos_im[1] - node_pos_i[1]
        dy10 = node_pos_ip[2] - node_pos_i[2]
        dy20 = node_pos_im[2] - node_pos_i[2]

        det_J = dx10 * dy20 - dx20 * dy10

        phi_ii_x = 0.5 * (-dy20 + dy10)^2 / det_J
        phi_ii_y = 0.5 * (dx20 - dx10)^2 / det_J

        phi_ip_x = 0.5 * (-dy20 + dy10) * dy20 / det_J
        phi_ip_y = -0.5 * (dx20 - dx10) * dx20 / det_J

        phi_im_x = -0.5 * (-dy20 + dy10) * dy10 / det_J
        phi_im_y = 0.5 * (dx20 - dx10) * dx10 / det_J

        surface_br = mesh.surfaces[cell.surface_id]

        matrix[node_id, node_id] += (phi_ii_x + phi_ii_y) * surface_br.thermal_conductivity;
        matrix[node_id, node_id_im] += (phi_im_x + phi_im_y) * surface_br.thermal_conductivity;
        matrix[node_id, node_id_ip] += (phi_ip_x + phi_ip_y) * surface_br.thermal_conductivity;

        vector[node_id] += (1.0 / 6.0) * surface_br.volumetric_heat_source * det_J
    end
end

function conver_boundaries!(matrix, vector, mesh, node_id)
    node = mesh.nodes[node_id]
    boundary1 = mesh.boundaries[node.boundaries[1]]
    boundary2 = mesh.boundaries[node.boundaries[2]]

    if boundary1.type == DIRICHLET && boundary2.type == DIRICHLET
        matrix[node_id, node_id] = 1.0
        vector[node_id] = 0.5 * (boundary1.value + boundary2.value)
    elseif boundary1.type == DIRICHLET
        matrix[node_id, node_id] = 1.0
        vector[node_id] = boundary1.value
    elseif boundary2.type == DIRICHLET
        matrix[node_id, node_id] = 1.0
        vector[node_id] = boundary2.value
    else
        error("undefined boundary type")
    end
end