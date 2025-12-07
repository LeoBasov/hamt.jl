using LinearSolve
using LinearAlgebra

include("constants.jl")

@enum CoordSystem CARTESIAN=1 CYLINDER=2

function solve_heat_equation!(solution, mesh, coord_system::CoordSystem)
    matrix, vector = convert_triangular_mesh(solution, mesh, coord_system)
    problem = LinearProblem(matrix, vector)
    sol = solve(problem)
    error = norm(solution - sol.u)
    copy!(solution, sol.u)

    return error
end

function convert_triangular_mesh(solution, mesh, coord_system::CoordSystem)
    matrix::Matrix{Float64} = zeros(length(mesh.nodes), length(mesh.nodes))
    vector::Vector{Float64} = zeros(length(mesh.nodes))

    for node_id=1:length(mesh.nodes)
        if length(mesh.nodes[node_id].boundaries) > 0
            conver_boundaries!(matrix, vector, mesh, node_id, solution)
        else
            convert_center!(matrix, vector, mesh, node_id, coord_system)
        end
    end

    return matrix, vector
end

function convert_center!(matrix, vector, mesh, node_id, coord_system::CoordSystem)
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

        if coord_system == CARTESIAN
            matrix[node_id, node_id] += (phi_ii_x + phi_ii_y) * surface_br.properties["thermal_conductivity"]
            matrix[node_id, node_id_im] += (phi_im_x + phi_im_y) * surface_br.properties["thermal_conductivity"]
            matrix[node_id, node_id_ip] += (phi_ip_x + phi_ip_y) * surface_br.properties["thermal_conductivity"]

            vector[node_id] += (1.0 / 6.0) * surface_br.properties["volumetric_heat_source"] * det_J
        elseif coord_system == CYLINDER
            int_r = (dy10 / 3.0) + (dy20 / 3.0) + node_pos_i[2]
            int_rb = (dy10 / 24.0) + (dy20 / 24.0) + (node_pos_i[2] / 6.0)

            matrix[node_id, node_id] += int_r * (phi_ii_x + phi_ii_y) * surface_br.properties["thermal_conductivity"]
            matrix[node_id, node_id_im] += int_r * (phi_im_x + phi_im_y) * surface_br.properties["thermal_conductivity"]
            matrix[node_id, node_id_ip] += int_r * (phi_ip_x + phi_ip_y) * surface_br.properties["thermal_conductivity"]

            vector[node_id] += int_rb * surface_br.properties["volumetric_heat_source"] * det_J
        else
            error("undefined coord system [" * string(coord_system) *"]")
        end
    end
end

function conver_boundaries!(matrix, vector, mesh, node_id, solution)
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
    elseif boundary1.type == NEUMANN && boundary2.type == NEUMANN
        set_neumann_boundary!(matrix, vector, mesh, node_id)
    elseif boundary1.type == RADIATION || boundary2.type == RADIATION
        set_radiation_boundary!(matrix, vector, mesh, node_id, solution)
    else
        error("undefined boundary type")
    end
end

function set_neumann_boundary!(matrix, vector, mesh, node_id)
    node = mesh.nodes[node_id]
    boundary1 = mesh.boundaries[node.boundaries[1]]
    boundary2 = mesh.boundaries[node.boundaries[2]]
    node_pos_left = mesh.nodes[node.adjacent_nodes[begin]].position
    node_pos_right = mesh.nodes[node.adjacent_nodes[end]].position
    rot_mat::Matrix{Float64} = zeros(3, 3)
    total_cell_area = 0.0

    rot_mat[1, 2] = 1.0;
    rot_mat[2, 1] = -1.0;
    rot_mat[3, 3] = 1.0;

    normal1 = rot_mat * (node_pos_left - node.position)
    normal2 = rot_mat * (node.position - node_pos_right)

    normal1 ./= norm(normal1)
    normal2 ./= norm(normal2)

    for cell_id in node.adjacent_cells
        total_cell_area += get_cell_area(mesh, cell_id)
    end

    for cell_id in node.adjacent_cells
        cell = mesh.cells[cell_id]
        factor = 1.0 / (2.0 * total_cell_area)

        for i=1:3
            pos_im = i == 1 ? 3 : i - 1
            pos_ip = i == 3 ? 1 : i + 1
            node_id_im = cell.nodes[pos_im]
            node_id_ip = cell.nodes[pos_ip]
            node_id_i = cell.nodes[i]
            node_pos_im = mesh.nodes[node_id_im].position
            node_pos_ip = mesh.nodes[node_id_ip].position

            matrix[node_id, node_id_i] += factor * dot(rot_mat * (node_pos_ip - node_pos_im), normal1)
            matrix[node_id, node_id_i] += factor * dot(rot_mat * (node_pos_ip - node_pos_im), normal2)
        end
    end

    vector[node_id] = boundary1.value + boundary2.value
end

function set_radiation_boundary!(matrix, vector, mesh, node_id, solution)
    node = mesh.nodes[node_id]
    boundary1 = mesh.boundaries[node.boundaries[1]]
    boundary2 = mesh.boundaries[node.boundaries[2]]
    side1 = get_side(node_id, mesh, 1)
    side2 = get_side(node_id, mesh, 2)
    node_pos_left = mesh.nodes[node.adjacent_nodes[begin]].position
    node_pos_right = mesh.nodes[node.adjacent_nodes[end]].position
    rot_mat::Matrix{Float64} = zeros(3, 3)
    total_cell_area = 0.0
    L_left = norm(node_pos_left - node.position)
    L_right = norm(node.position - node_pos_right)
    L = L_left + L_right
    normal::Vector{Float64} = []
    conf_factor_backgr = 0.0

    rot_mat[1, 2] = 1.0;
    rot_mat[2, 1] = -1.0;
    rot_mat[3, 3] = 1.0;

    for cell_id in node.adjacent_cells
        total_cell_area += get_cell_area(mesh, cell_id)
    end

    if boundary1.type == RADIATION && boundary2.type == RADIATION
        epsilon = (L_left * boundary1.value + L_right * boundary2.value) / L
        copy!(normal, 0.5 * rot_mat * (node_pos_left - node.position) + 0.5 * rot_mat * (node.position - node_pos_right))
        conf_factor_backgr = (L_left * side1.conf_factor_backgr + L_right * side2.conf_factor_backgr) / L
    elseif boundary1.type == RADIATION
        epsilon = boundary1.value;
        copy!(normal, rot_mat * (node_pos_left - node.position))
        conf_factor_backgr = side1.conf_factor_backgr
    else
        epsilon = boundary2.value;
        copy!(normal, rot_mat * (node.position - node_pos_right))
        conf_factor_backgr = side2.conf_factor_backgr
    end

    normal ./= norm(normal)
    matrix[node_id, node_id] -= 4.0 * epsilon * σ * solution[node_id]^3 * conf_factor_backgr
    vector[node_id] += -3.0 * epsilon * σ * solution[node_id]^4 * conf_factor_backgr

    if boundary1.type == RADIATION && boundary2.type == RADIATION
        for seen_side in side1.seen_sides
            set_radtion_values!(matrix, vector, mesh, node_id, solution, seen_side, epsilon)
        end

        for seen_side in side2.seen_sides
            set_radtion_values!(matrix, vector, mesh, node_id, solution, seen_side, epsilon)
        end
    elseif boundary1.type == RADIATION
        for seen_side in side1.seen_sides
            set_radtion_values!(matrix, vector, mesh, node_id, solution, seen_side, epsilon)
        end
    else
        for seen_side in side2.seen_sides
            set_radtion_values!(matrix, vector, mesh, node_id, solution, seen_side, epsilon)
        end
    end

    for cell_id in node.adjacent_cells
        cell = mesh.cells[cell_id]
        pos_i = findall(x -> x == node_id, cell.nodes)[1]
        pos_ip = pos_i == 3 ? 1 : pos_i + 1
        pos_im = pos_i == 1 ? 3 : pos_i - 1
        node_id_ip = cell.nodes[pos_ip]
        node_id_im = cell.nodes[pos_im]
        frac = get_cell_area(mesh, cell_id) / total_cell_area
        surface = mesh.surfaces[cell.surface_id]
        coeffs = -frac * surface.properties["thermal_conductivity"] * calc_normal_derevative_coefficients(mesh, normal, cell_id, node_id)

        matrix[node_id, node_id] += coeffs[1]

        matrix[node_id, node_id_ip] += coeffs[2]
        matrix[node_id, node_id_im] += coeffs[3]
    end
end

function set_radtion_values!(matrix, vector, mesh, node_id, solution, seen_side, epsilon)
    other_cell = mesh.cells[seen_side[1]]
    other_side_id = seen_side[2][1]
    other_node_id1 = other_cell.nodes[other_side_id]
    other_node_id2 = other_cell.nodes[other_side_id == 3 ? 1 : other_side_id + 1]

    matrix[node_id, other_node_id1] += 2.0 * epsilon * σ * solution[other_node_id1]^3 * seen_side[3][1]
    matrix[node_id, other_node_id2] += 2.0 * epsilon * σ * solution[other_node_id2]^3 * seen_side[3][1]

    vector[node_id] += 1.5 * epsilon * σ * solution[other_node_id1]^4 * seen_side[3][1]
    vector[node_id] += 1.5 * epsilon * σ * solution[other_node_id2]^4 * seen_side[3][1]

    matrix[node_id, node_id] -= 4.0 * epsilon * σ * solution[node_id]^3 * seen_side[3][1]
    vector[node_id] += -3.0 * epsilon * σ * solution[node_id]^4 * seen_side[3][1]
end

function calc_normal_derevative_coefficients(mesh, normal_vec, cell_id, node_id)
    node = mesh.nodes[node_id]
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
    det_J = dx10 * dy20 - dx20 * dy10;
    coeffs = zeros(3)

    coeffs[1] = (normal_vec[1] * (dy10 - dy20) + normal_vec[2] * (dx20 - dx10)) / det_J
    coeffs[2] = (normal_vec[1] * dy20 - normal_vec[2] * dx20) / det_J
    coeffs[3] = (-normal_vec[1] * dy10 + normal_vec[2] * dx10) / det_J

    return coeffs
end