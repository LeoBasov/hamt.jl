using LinearAlgebra

@enum BoundaryType NEUMANN=1 DIRICHLET=2 RADIATION=3 HEAT_FLUX=4

mutable struct Boundary
    type::BoundaryType
    value
    Boundary() = new(DIRICHLET, 1.0)
end

mutable struct Surface
    properties::Dict{String, Number}

    function Surface()
        properties::Dict{String, Number} = Dict()

        properties["thermal_conductivity"] = 1.0
        properties["volumetric_heat_source"] = 0.0

        new(properties)
    end
end

mutable struct Node
    position::Vector
    adjacent_nodes::Vector{Int}  # ordered counter clockwise
    adjacent_cells::Vector{Int}  # ordered counter clockwise
    boundaries::Vector{Int}

    Node() = new([], [], [], [])
end

mutable struct Side
    boundary::Int
    seen_sides::Vector{Int} # relevant for radiation modeling
    normal::Vector{Float64}

    Side() = new(-1, [], zeros(3))
end

mutable struct Cell
    barycentre::Vector{Float64}
    nodes::Vector{Int}
    sides::Vector{Side}
    surface_id::Int

    Cell() = new([0.0, 0.0, 0.0], [-1, -1, -1], [Side(), Side(), Side()], -1)
end

function is_surface_cell(cell::Cell)
    sum([side.boundary for side in cell.sides]) > -1
end

mutable struct Mesh
    boundaries::Vector{Boundary}
    surfaces::Vector{Surface}
    nodes::Vector{Node}
    cells::Vector{Cell}

    boundary_names::Dict{String, Int}
    surface_names::Dict{String, Int}
    boundary_ids::Dict{Int, Int}
    surface_ids::Dict{Int, Int}

    Mesh() = new([], [], [], [], Dict(), Dict(), Dict(), Dict())
end

function has_radiation_boundary(mesh)
    for boundary in mesh.boundaries
        if boundary.type == RADIATION
            return true
        end
    end
    return false
end

function set_boundary!(mesh, name, type, value)
    bound_id = mesh.boundary_names[name]
    boundary = mesh.boundaries[bound_id]
    boundary.type = type
    boundary.value = value
end

function set_surface_property!(mesh, name, type, value)
    surf_id = mesh.surface_names[name]
    surface = mesh.surfaces[surf_id]

    if type in keys(surface.properties)
        surface.properties[type] = value
    else
        throw(ErrorException("type [" * type * "] is not a surface property"))
    end
end

function get_cell_area(mesh, cell_id)
    cell = mesh.cells[cell_id]
    point1 = mesh.nodes[cell.nodes[1]].position
    point2 = mesh.nodes[cell.nodes[2]].position
    point3 = mesh.nodes[cell.nodes[3]].position
    dist1 = point2 - point1
    dist2 = point3 - point1
    cross_prod = cross(dist1, dist2)

    return 0.5 * norm(cross_prod)
end

function read_Gmsh_file(file_name)
	str = ""
	res = Dict()

	open(file_name) do file
		while !eof(file)
			line = readline(file)
			
			if length(str) == 0 && line[1] == '$'
				str = lstrip(line, '$')
				res[str] = []
			elseif length(str) > 0 && line[1] == '$'
				str = ""
			else
				splt = split(line, ' ')
				push!(res[str], splt)
			end
		end
	end
	
	return res
end

function convert_Gmsh2_to_Mesh(gmsh_file)
    mesh = Mesh()

    setup_physical_properties!(mesh, gmsh_file)
    setup_cells_and_nodes!(mesh, gmsh_file)
    connect_mesh!(mesh)

    return mesh
end

function setup_physical_properties!(mesh, gmsh_file)
    for name in gmsh_file["PhysicalNames"]
        if length(name) == 3 && name[1] == "1"
            boundary = Boundary()
            push!(mesh.boundaries, boundary)

            name_str = rstrip(lstrip(name[3], '"'), '"')
            mesh.boundary_names[name_str] = length(mesh.boundaries)
            mesh.boundary_ids[parse(Int, name[2])] = length(mesh.boundaries)
        elseif length(name) == 3 && name[1] == "2"
            surface = Surface()
            push!(mesh.surfaces, surface)

            name_str = rstrip(lstrip(name[3], '"'), '"')
            mesh.surface_names[name_str] = length(mesh.surfaces)
            mesh.surface_ids[parse(Int, name[2])] = length(mesh.surfaces)
        end
    end
end

function setup_cells_and_nodes!(mesh, gmsh_file)
    # setup nodes
    for i = 2:length(gmsh_file["Nodes"])
        gmsh_node = gmsh_file["Nodes"][i]
        x = parse(Float64, gmsh_node[2])
        y = parse(Float64, gmsh_node[3])
        z = parse(Float64, gmsh_node[4])
        node = Node()
        node.position = [x, y, z]
        push!(mesh.nodes, node)
    end

    # setup cells
    for element in gmsh_file["Elements"]
        if length(element) > 1 && element[2] == "2"
            cell = Cell()
            surf_id = parse(Int, element[4])
            cell.surface_id = mesh.surface_ids[surf_id]
            cell.nodes[1] = parse(Int, element[6])
            cell.nodes[2] = parse(Int, element[7])
            cell.nodes[3] = parse(Int, element[8])
            cell.barycentre = (mesh.nodes[cell.nodes[1]].position + mesh.nodes[cell.nodes[2]].position + mesh.nodes[cell.nodes[3]].position) / 3.0
            push!(mesh.cells, cell)
        end
    end

    # setup boundaries
    for element in gmsh_file["Elements"]
        if length(element) > 1 && element[2] == "1"
            for cell in mesh.cells
                items = findall(x -> x == parse(Int, element[6]) || x == parse(Int,element[7]), cell.nodes)
                if length(items) == 2
                    if items[1] == 1 && items[2] == 2
                        id = parse(Int, element[4])
                        cell.sides[1].boundary = mesh.boundary_ids[id] 
                    elseif items[1] == 2 && items[2] == 3
                        id = parse(Int, element[4])
                        cell.sides[2].boundary = mesh.boundary_ids[id] 
                    elseif items[1] == 1 && items[2] == 3
                        id = parse(Int, element[4])
                        cell.sides[3].boundary = mesh.boundary_ids[id] 
                    else
                        error("unacceptrable combination of cell indices")
                    end
                end
            end
        end
    end
end

function connect_mesh!(mesh)
    # setup adjacent cells
    for n=1:length(mesh.nodes), c=1:length(mesh.cells)
        if n in mesh.cells[c].nodes
            push!(mesh.nodes[n].adjacent_cells, c)
        end
    end

    # sort adjacent cell
    for n=1:length(mesh.nodes)
        node = mesh.nodes[n]
        for c=1:length(node.adjacent_cells)
            cell = mesh.cells[node.adjacent_cells[c]]
            pos = findall(x -> x == n, cell.nodes)[begin]
            if cell.sides[pos].boundary > -1
                c_old = node.adjacent_cells[1]
                node.adjacent_cells[1] = node.adjacent_cells[c]
                node.adjacent_cells[c] = c_old
                break
            end
        end

        for c_first=1:length(node.adjacent_cells)
            id1 = node.adjacent_cells[c_first]
            pos_c1 = findall(x -> x == n, mesh.cells[id1].nodes)[begin]
            pos_c11 = pos_c1 > 1 ? pos_c1 - 1 : 3
            node_id1 = mesh.cells[id1].nodes[pos_c11]
            for c_second=(c_first+1):length(node.adjacent_cells)
                id_second = node.adjacent_cells[c_second]
                pos_c2 = findall(x -> x == n, mesh.cells[id_second].nodes)[begin]
                pos_c22 =  pos_c2 < 3 ? pos_c2 + 1 : 1
                node_id2 = mesh.cells[id_second].nodes[pos_c22]

                if node_id1 == node_id2
                    c2_new = node.adjacent_cells[c_second]
                    node.adjacent_cells[c_second] = node.adjacent_cells[c_first + 1]
                    node.adjacent_cells[c_first + 1] = c2_new
                    break
                end
            end
        end
    end

    # setup adjacent nodes
    for n=1:length(mesh.nodes), c=1:length(mesh.nodes[n].adjacent_cells)
        node = mesh.nodes[n]
        cell = mesh.cells[node.adjacent_cells[c]]
        pos_vec = findall(x -> x == n, cell.nodes)

        if length(pos_vec) == 1
            pos = pos_vec[1]
            pos_p1 = pos < 3 ? pos + 1 : 1
            pos_p2 = pos > 1 ? pos - 1 : 3
            if !(cell.nodes[pos_p1] in node.adjacent_nodes) push!(node.adjacent_nodes, cell.nodes[pos_p1]) end
            if !(cell.nodes[pos_p2] in node.adjacent_nodes) push!(node.adjacent_nodes, cell.nodes[pos_p2]) end
        end
    end

    # connect nodes to boundaries
    for n=1:length(mesh.nodes)
        node = mesh.nodes[n]
        for c in node.adjacent_cells
            cell = mesh.cells[c]
            pos1 = findall(x -> x == n, cell.nodes)[1]
            pos2 = pos1 == 1 ? 3 : pos1 - 1
            if cell.sides[pos1].boundary > -1
                push!(node.boundaries, cell.sides[pos1].boundary)
            end
            if cell.sides[pos2].boundary > -1
                push!(node.boundaries, cell.sides[pos2].boundary)
            end
        end
    end

    # set normal vector on sides
    rot_mat::Matrix{Float64} = zeros(3, 3)

    rot_mat[1, 2] = 1.0;
    rot_mat[2, 1] = -1.0;
    rot_mat[3, 3] = 1.0;

    for cell in mesh.cells
        nodepos1 = mesh.nodes[cell.nodes[1]].position
        nodepos2 = mesh.nodes[cell.nodes[2]].position
        nodepos3 = mesh.nodes[cell.nodes[3]].position

        cell.sides[1].normal =  rot_mat * (nodepos1 - nodepos2)
        cell.sides[2].normal =  rot_mat * (nodepos2 - nodepos3)
        cell.sides[3].normal =  rot_mat * (nodepos3 - nodepos1)
    end
end

function connect_LineOfSite_cells!(mesh)
    for cell_id in eachindex(mesh.cells)
        cell = mesh.cells[cell_id]
        if is_surface_cell(cell)
            for side_id in eachindex(cell.sides)
                side = cell.sides[side_id]
                if side.boundary > 0 &&  mesh.boundaries[side.boundary].type == RADIATION
                    find_LOS_cells!(mesh, cell_id, side_id)
                end
            end
        end
    end
end

function find_LOS_cells!(mesh, cell_id, side_id)
    rot_mat::Matrix{Float64} = zeros(3, 3)

    rot_mat[1, 2] = 1.0;
    rot_mat[2, 1] = -1.0;
    rot_mat[3, 3] = 1.0;

    cell = mesh.cells[cell_id]
    for other_cell_id in eachindex(mesh.cells)
        other_cell = mesh.cells[other_cell_id]
        if cell_id != other_cell_id && is_surface_cell(other_cell)
            node_id1 = cell.nodes[side_id]
            node_id2 = cell.nodes[side_id == 3 ? 1 : side_id + 1]
            mid_point = 0.5*(mesh.nodes[node_id1].position + mesh.nodes[node_id2].position)
            line = other_cell.barycentre - mid_point

            #TODO if dot(normal side, normal side2) < 0 && if lline intersect side
                # chek if line intersects oder cells
        end
    end
end