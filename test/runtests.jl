using HAMT
using Test

function test_read_Gmsh_file()
	gmsh_file = HAMT.read_Gmsh_file("test_data/block_single_triangular.msh")

	@test length(gmsh_file) == 4
	@test length(gmsh_file["Nodes"]) == 6
	@test gmsh_file["Nodes"][1][1] == "5"
	@test length(gmsh_file["Nodes"][2]) == 4
	@test gmsh_file["Nodes"][2][3] == "0.5"
end

function test_convert_Gmsh2_to_Mesh()
	gmsh_file = HAMT.read_Gmsh_file("test_data/block_single_triangular.msh")
	mesh = HAMT.convert_Gmsh2_to_Mesh(gmsh_file)

	@test length(mesh.boundaries) == 4
	@test length(mesh.boundary_names) == 4
	@test mesh.boundary_names["top"] == 3
	@test length(mesh.surfaces) == 1
	@test length(mesh.surface_names) == 1
	@test mesh.surface_names["surf"] == 1

	@test length(mesh.nodes) == 5
	@test mesh.nodes[3].position[1] == 1.5
	@test mesh.nodes[3].position[2] == 1.0
	@test mesh.nodes[3].position[3] == 0.0

	@test length(mesh.cells) == 4
	@test mesh.cells[2].nodes[1] == 1
	@test mesh.cells[2].nodes[2] == 5
	@test mesh.cells[2].nodes[3] == 4
	@test mesh.cells[2].surface_id == 1
	@test mesh.cells[2].barycentre[1] == 3.25/3.0
	@test mesh.cells[2].barycentre[2] == 2.25/3.0
	@test mesh.cells[2].barycentre[3] == 0.0

	@test mesh.cells[1].nodes[1] == 2
	@test mesh.cells[1].nodes[2] == 5
	@test mesh.cells[1].boundaries[1] == -1
	@test mesh.cells[1].boundaries[2] == -1
	@test mesh.cells[1].boundaries[3] == 1

	@test mesh.cells[2].nodes[1] == 1
	@test mesh.cells[2].nodes[2] == 5
	@test mesh.cells[2].boundaries[1] == -1
	@test mesh.cells[2].boundaries[2] == -1
	@test mesh.cells[2].boundaries[3] == 4

	@test mesh.cells[3].nodes[1] == 3
	@test mesh.cells[3].nodes[2] == 5
	@test mesh.cells[3].boundaries[1] == -1
	@test mesh.cells[3].boundaries[2] == -1
	@test mesh.cells[3].boundaries[3] == 2

	@test mesh.cells[4].nodes[1] == 4
	@test mesh.cells[4].nodes[2] == 5
	@test mesh.cells[4].boundaries[1] == -1
	@test mesh.cells[4].boundaries[2] == -1
	@test mesh.cells[4].boundaries[3] == 3

	@test length(mesh.nodes[1].adjacent_cells) == 2
	@test length(mesh.nodes[2].adjacent_cells) == 2
	@test length(mesh.nodes[3].adjacent_cells) == 2
	@test length(mesh.nodes[4].adjacent_cells) == 2
	@test length(mesh.nodes[5].adjacent_cells) == 4

	@test mesh.nodes[5].adjacent_cells[1] == 1
	@test mesh.nodes[5].adjacent_cells[2] == 3
	@test mesh.nodes[5].adjacent_cells[3] == 4
	@test mesh.nodes[5].adjacent_cells[4] == 2

	@test length(mesh.nodes[1].adjacent_nodes) == 3
	@test mesh.nodes[1].adjacent_nodes[1] == 2
	@test mesh.nodes[1].adjacent_nodes[2] == 5
	@test mesh.nodes[1].adjacent_nodes[3] == 4

	@test length(mesh.nodes[5].adjacent_nodes) == 4
	@test mesh.nodes[5].adjacent_nodes[1] == 1
	@test mesh.nodes[5].adjacent_nodes[2] == 2
	@test mesh.nodes[5].adjacent_nodes[3] == 3
	@test mesh.nodes[5].adjacent_nodes[4] == 4
end

function test_ntr_mesh()
	gmsh_file = HAMT.read_Gmsh_file("test_data/ntr.msh")
	mesh = HAMT.convert_Gmsh2_to_Mesh(gmsh_file)

	@test length(mesh.nodes[2].adjacent_cells) == 6
	@test mesh.nodes[2].adjacent_cells[1] == 1850
	@test mesh.nodes[2].adjacent_cells[2] == 1846
	@test mesh.nodes[2].adjacent_cells[3] == 498
	@test mesh.nodes[2].adjacent_cells[4] == 600
	@test mesh.nodes[2].adjacent_cells[5] == 147
	@test mesh.nodes[2].adjacent_cells[6] == 111

	@test length(mesh.nodes[2].adjacent_nodes) == 7
	@test mesh.nodes[2].adjacent_nodes[1] == 303
	@test mesh.nodes[2].adjacent_nodes[2] == 1090
	@test mesh.nodes[2].adjacent_nodes[3] == 66
	@test mesh.nodes[2].adjacent_nodes[4] == 531
	@test mesh.nodes[2].adjacent_nodes[5] == 38
	@test mesh.nodes[2].adjacent_nodes[6] == 375
	@test mesh.nodes[2].adjacent_nodes[7] == 37
end

@testset "Mesh.jl" begin
	test_read_Gmsh_file()
	test_convert_Gmsh2_to_Mesh()
	test_ntr_mesh()
end

@testset "Solver.jl" begin
	gmsh_file = HAMT.read_Gmsh_file("test_data/block_single_triangular.msh")
	mesh = HAMT.convert_Gmsh2_to_Mesh(gmsh_file)
	matrix, vector = HAMT.convert_triangular_mesh(mesh)
	solution = HAMT.solve_heat_equation(mesh)

	@test size(matrix) === (length(mesh.nodes), length(mesh.nodes))
	@test length(vector) == length(mesh.nodes)
	@test length(solution) == length(mesh.nodes)
end