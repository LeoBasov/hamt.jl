@enum BoundaryType NEUMANN=1 DIRICHLET=2 RADIATION=3 HEAT_FLUX=4

mutable struct Boundary
    type::BoundaryType
    value
    Boundary() = new(DIRICHLET, 0.0)
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

    #size_t GetNodePos(const size_t& node_id) const;
    #bool IsInCell(const size_t& node_id) const;

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
    # setup adjacent nodes
    for i=1:length(mesh.cells)
        for node_id in mesh.cells[i].nodes
            push!(mesh.nodes[node_id].adjacent_cells, i)
        end
    end
end