@enum BoundaryType NEUMANN=1 DIRICHLET=2 RADIATION=3 HEAT_FLUX=4

mutable struct Boundary
    type::BoundaryType
    value
    Boundary() = new(DIRICHLET, 1.0)
end

mutable struct Surface
    thermal_conductivity
    heat_capacity
    density
    volumetric_heat_source

    Surface() = new(1.0, 1.0, 1.0, 0.0)
end

mutable struct Node
    position::Vector
    adjacent_nodes::Vector{Int}  # ordered counter clockwise
    adjacent_cells::Vector{Int}  # ordered counter clockwise
    boundaries::Vector{Int}

    Node() = new([], [], [], [])
end

mutable struct Cell
    barycentre::Vector{Float64}
    nodes::Vector{Int}
    boundaries::Vector{Int}
    surface_id::Int

    Cell() = new([0.0, 0.0, 0.0], [-1, -1, -1], [-1, -1, -1], -1)
end

mutable struct Mesh
    boundaries::Vector{Boundary}
    surfaces::Vector{Surface}
    nodes::Vector{Node}
    cells::Vector{Cell}

    boundary_names::Dict{String, Int}
    surface_names::Dict{String, Int}

    Mesh() = new([], [], [], [], Dict(), Dict())
end

function set_boundary!(mesh, name, type, value)
    bound_id = mesh.boundary_names[name]
    boundary = mesh.boundaries[bound_id]
    boundary.type = type
    boundary.value = value
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
        elseif length(name) == 3 && name[1] == "2"
            surface = Surface()
            push!(mesh.surfaces, surface)

            name_str = rstrip(lstrip(name[3], '"'), '"')
            mesh.surface_names[name_str] = length(mesh.surfaces)
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
            cell.surface_id = parse(Int, element[4])
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
                        cell.boundaries[1] = parse(Int, element[4])
                    elseif items[1] == 2 && items[2] == 3
                        cell.boundaries[2] = parse(Int, element[4])
                    elseif items[1] == 1 && items[2] == 3
                        cell.boundaries[3] = parse(Int, element[4])
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
        if length(node.adjacent_cells) < 3
            continue
        end

        c1 = 1
        while true
            if c1 >= (length(node.adjacent_cells) - 1)
                break
            end

            id1 = node.adjacent_cells[c1]
            pos_c1 = findall(x -> x == n, mesh.cells[id1].nodes)[begin]
            pos_c11 = pos_c1 > 1 ? pos_c1 - 1 : 3
            node_id1 = mesh.cells[id1].nodes[pos_c11]

            for cc=(c1 + 1):length(node.adjacent_cells)
                id2 = node.adjacent_cells[cc]
                pos_c2 = findall(x -> x == n, mesh.cells[id2].nodes)[begin]
                pos_c22 =  pos_c2 < 3 ? pos_c2 + 1 : 1
                node_id2 = mesh.cells[id2].nodes[pos_c22]

                if node_id1 == node_id2
                    c2_new = node.adjacent_cells[cc]
                    node.adjacent_cells[cc] = node.adjacent_cells[c1 + 1]
                    node.adjacent_cells[c1 + 1] = c2_new
                    c1 += 1
                    break
                end

                if cc == length(node.adjacent_cells)
                    for q=1:length(node.adjacent_cells)
                        if q!=c1 && sum(mesh.cells[node.adjacent_cells[q]].boundaries) > -3
                            c_new = node.adjacent_cells[q]
                            node.adjacent_cells[q] = node.adjacent_cells[1]
                            node.adjacent_cells[1] = c_new
                            c1 = 1
                            break
                        end
                    end
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
            if cell.boundaries[pos1] > -1
                push!(node.boundaries, cell.boundaries[pos1])
            end
            if cell.boundaries[pos2] > -1
                push!(node.boundaries, cell.boundaries[pos2])
            end
        end
    end
end