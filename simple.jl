# simple.jl
using Agents, Random

# Definir el agente `box`
@agent struct box(GridAgent{2}) 
end

function position_Boxes(griddims = (40, 40), max_boxes = 40)
    # Crear un espacio de cuadrícula
    space = GridSpaceSingle(griddims; periodic = false, metric = :manhattan)

    # Creación del modelo de agente basado en `box`
    forest = StandardABM(box, space; scheduler = Schedulers.Randomly())

    # Filtrar posiciones para excluir las tres últimas filas
    all_positions = [pos for pos in positions(forest) if pos[2] <= griddims[2] - 3]
    shuffled_positions = shuffle!(all_positions)

    # Seleccionar posiciones aleatorias, limitadas a max_boxes o menos
    selected_positions = shuffled_positions[1:min(max_boxes, length(shuffled_positions))]

    # Añadir cajas en las posiciones seleccionadas aleatoriamente
    for pos in selected_positions
        add_agent!(pos, forest)
    end
    
    return forest
end
