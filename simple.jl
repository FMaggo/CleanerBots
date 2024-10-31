# simple.jl
using Agents, Random

# Definir el agente `box`
@agent struct box(GridAgent{2}) 
end

function position_Boxes(griddims = (40, 40), max_boxes = 40)
    # Crear un espacio de cuadrícula
    space = GridSpaceSingle(griddims; periodic = false, metric = :manhattan)

    # Función de paso para cada agente (si se necesita)
    function dummy_agent_step!(agent, model)
        # Agrega algún comportamiento si es necesario
    end

    # Crear el modelo
    caja = StandardABM(box, space; scheduler = Schedulers.Randomly(), agent_step! = dummy_agent_step!)

    # Generar todas las posiciones posibles en la cuadrícula
    all_positions = [(x, y) for x in 1:2:griddims[1], y in 1:2:griddims[2]]
    
    # Barajar las posiciones
    shuffled_positions = shuffle!(all_positions)

    # Seleccionar las primeras `max_boxes` posiciones sin repetición
    selected_positions = shuffled_positions[1:min(max_boxes, length(shuffled_positions))]

    # Añadir las cajas en las posiciones seleccionadas
    for pos in selected_positions
        add_agent!(pos, caja)
    end

    return caja
end
