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
	@test mesh.cells[1].sides[1].boundary == -1
	@test mesh.cells[1].sides[2].boundary == -1
	@test mesh.cells[1].sides[3].boundary == 1

	@test mesh.cells[2].nodes[1] == 1
	@test mesh.cells[2].nodes[2] == 5
	@test mesh.cells[2].sides[1].boundary == -1
	@test mesh.cells[2].sides[2].boundary == -1
	@test mesh.cells[2].sides[3].boundary == 4

	@test mesh.cells[3].nodes[1] == 3
	@test mesh.cells[3].nodes[2] == 5
	@test mesh.cells[3].sides[1].boundary == -1
	@test mesh.cells[3].sides[2].boundary == -1
	@test mesh.cells[3].sides[3].boundary == 2

	@test mesh.cells[4].nodes[1] == 4
	@test mesh.cells[4].nodes[2] == 5
	@test mesh.cells[4].sides[1].boundary == -1
	@test mesh.cells[4].sides[2].boundary == -1
	@test mesh.cells[4].sides[3].boundary == 3

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

	@test length(mesh.nodes[1].boundaries) == 2
	@test length(mesh.nodes[2].boundaries) == 2
	@test length(mesh.nodes[3].boundaries) == 2
	@test length(mesh.nodes[4].boundaries) == 2
	@test length(mesh.nodes[5].boundaries) == 0
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

	@test HAMT.is_surface_cell(mesh.cells[898]) == true
	@test HAMT.is_surface_cell(mesh.cells[1960]) == false
end

@testset "Mesh.jl" begin
	test_read_Gmsh_file()
	test_convert_Gmsh2_to_Mesh()
	test_ntr_mesh()
end

function simple_triangular_solver_test()
	background_radiaton_only = false
	gmsh_file = HAMT.read_Gmsh_file("test_data/block_single_triangular.msh")
	mesh = HAMT.convert_Gmsh2_to_Mesh(gmsh_file)
	solution::Vector{Float64} =  []
	resize!(solution, length(mesh.nodes))
	HAMT.set_boundary!(mesh, "top", HAMT.DIRICHLET, 1.0, background_radiaton_only)
	HAMT.set_boundary!(mesh, "buttom", HAMT.DIRICHLET, 1.0, background_radiaton_only)
	HAMT.set_boundary!(mesh, "left", HAMT.DIRICHLET, 1.0, background_radiaton_only)
	HAMT.set_boundary!(mesh, "right", HAMT.DIRICHLET, 1.0, background_radiaton_only)
	matrix, vector = HAMT.convert_triangular_mesh(solution, mesh, CARTESIAN)
	HAMT.solve_heat_equation!(solution, mesh, CARTESIAN)

	@test size(matrix) === (length(mesh.nodes), length(mesh.nodes))
	@test length(vector) == length(mesh.nodes)
	@test length(solution) == length(mesh.nodes)
	
	#TODO: update tests
	@test vector[1] == 1.0
	@test vector[2] == 1.0
	@test vector[3] == 1.0
	@test vector[4] == 1.0
	@test vector[5] == 0.0

	#TODO: update tests
	@test matrix[1, 1] == 1.0
	@test matrix[2, 2] == 1.0
	@test matrix[3, 3] == 1.0
	@test matrix[4, 4] == 1.0

	#TODO: update tests
	@test matrix[5, 1] == -1.0
	@test matrix[5, 2] == -1.0
	@test matrix[5, 3] == -1.0
	@test matrix[5, 4] == -1.0
	@test matrix[5, 5] == 4.0

	#TODO: update tests
	@test solution[1] == 1.0
	@test solution[2] == 1.0
	@test solution[3] == 1.0
	@test solution[4] == 1.0
	@test solution[5] == 1.0
end

function set_boundary_test()
	background_radiaton_only = false
	gmsh_file = HAMT.read_Gmsh_file("test_data/block_single_triangular.msh")
	mesh = HAMT.convert_Gmsh2_to_Mesh(gmsh_file)
	HAMT.set_boundary!(mesh, "top", HAMT.DIRICHLET, 3.0, background_radiaton_only)
	HAMT.set_boundary!(mesh, "buttom", HAMT.DIRICHLET, 1.0, background_radiaton_only)
	HAMT.set_boundary!(mesh, "left", HAMT.NEUMANN, 0.0, background_radiaton_only)
	HAMT.set_boundary!(mesh, "right", HAMT.NEUMANN, 0.0, background_radiaton_only)
	solution::Vector{Float64} = []
	resize!(solution, length(mesh.nodes))
	matrix, vector = HAMT.convert_triangular_mesh(solution, mesh, CARTESIAN)
	HAMT.solve_heat_equation!(solution, mesh, CARTESIAN)

	@test vector[1] == 1.0
	@test vector[2] == 1.0
	@test vector[3] == 3.0
	@test vector[4] == 3.0
	@test vector[5] == 0.0

	@test solution[1] == 1.0
	@test solution[2] == 1.0
	@test solution[3] == 3.0
	@test solution[4] == 3.0
	@test solution[5] == 2.0
end

@testset "Solver.jl" begin
	simple_triangular_solver_test()
	set_boundary_test()
end