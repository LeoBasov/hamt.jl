using WriteVTK
using HAMT

function write_vtk(file_name, mesh, solution, surface)
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

    if surface == false
        return
    end

    # lines stuff
    lines::Vector{MeshCell{PolyData.Lines}} = []

    for cell in mesh.cells
        for i in 1:3            
            for seen_side in cell.sides[i].seen_sides
                other_cell = mesh.cells[seen_side[1]]

                for side in seen_side[2]
                    p = side == 3 ? 1 : side + 1
                    push!(lines, MeshCell(PolyData.Lines(), (other_cell.nodes[side], other_cell.nodes[p])))
                end
            end
        end
    end

    vtk_grid(file_name * "_surf", points, lines) do vtk
    #    vtk["temperature", VTKPointData()] = sol
    end
end