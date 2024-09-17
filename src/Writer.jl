using WriteVTK
using HAMT

function write_mesh(mesh, solution)
    points::Matrix{Float64} = zeros(3, 3*length(mesh.cells))
    cells::Vector{MeshCell} = []
    sol::Matrix{Float64} = zeros(1, 3*length(mesh.cells))

    for cell in mesh.cells
        push!(cells, MeshCell(VTKCellTypes.VTK_TRIANGLE, cell.nodes))
        for node_id in cell.nodes
            points[1, node_id] = mesh.nodes[node_id].position[1]
            points[2, node_id] = mesh.nodes[node_id].position[2]
            points[3, node_id] = mesh.nodes[node_id].position[3]
            sol[1, node_id] = solution[node_id]
        end
    end

    vtk_grid("filename", points, cells) do vtk
        vtk["temperature", VTKPointData()] = sol
    end
end