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
end

@testset "Mesh.jl" begin
	test_read_Gmsh_file()
	test_convert_Gmsh2_to_Mesh()
end
