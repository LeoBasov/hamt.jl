using WriteVTK
using HAMT

function write_mesh(file_name, mesh, solution)
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

    vtk_grid(file_name, points, cells) do vtk
        vtk["temperature", VTKPointData()] = sol
    end

    # lines stuff
    lines::Vector{MeshCell{PolyData.Lines}} = []

    for cell in mesh.cells
        for i in 1:3
            if cell.boundaries[i] > -1
                p = i == 3 ? 1 : i + 1
                push!(lines, MeshCell(PolyData.Lines(), (cell.nodes[i],cell.nodes[p])))
            end
        end
    end

    vtk_grid(file_name * "_surf", points, lines) do vtk
    #    vtk["temperature", VTKPointData()] = sol
    end
end