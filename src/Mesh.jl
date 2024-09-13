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

mutable struct Mesh
    boundaries::Vector{Boundary}
    surfaces::Vector{Surface}
    nodes::Vector{Node}

    boundary_names::Dict{String, Int}
    surface_names::Dict{String, Int}

    Mesh() = new([], [], [], Dict(), Dict())
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
    for i = 2:length(gmsh_file["Nodes"])
        gmsh_node = gmsh_file["Nodes"][i]
        x = parse(Float64, gmsh_node[2])
        y = parse(Float64, gmsh_node[3])
        z = parse(Float64, gmsh_node[4])
        node = Node()
        node.position = [x, y, z]
        push!(mesh.nodes, node)
    end
end