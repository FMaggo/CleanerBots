using Agents
using Random

# Actualización de la definición del agente Robot
@agent struct Robot(GridAgent{2})
    has_box::Bool       # Indica si el robot lleva una caja
    movements::Int      # Contador de movimientos realizados
    strategy::Int       # Estrategia que sigue el robot
    # El campo id ya está incluido automáticamente
end

# Función para inicializar el modelo
function initialize_model(num_boxes::Int; strategies=Dict())
    space = GridSpace((40, 40); periodic=false)
    model = ABM(Robot, space; scheduler=Schedulers.Randomly())

    # Posiciones disponibles (celdas vacías y no paredes)
    all_positions = [(x, y) for x in 1:40, y in 1:40]

    # Colocar cajas en posiciones aleatorias
    box_positions = sample(all_positions, num_boxes; replace=false)
    for pos in box_positions
        # Marca la celda con el número de cajas (comenzando en 1)
        set_prop!(model.space, pos, :box_height, 1)
    end

    # Colocar robots en posiciones aleatorias en celdas vacías
    available_positions = setdiff(all_positions, box_positions)
    robot_positions = sample(available_positions, 5; replace=false)
    for (i, pos) in enumerate(robot_positions)
        strategy = haskey(strategies, i) ? strategies[i] : 1
        add_agent!(Robot(pos; has_box=false, movements=0, strategy=strategy), model)
    end

    # Inicializar propiedades del modelo
    model.properties[:time_steps] = 0
    model.properties[:movements] = []
    model.properties[:box_positions] = box_positions

    return model
end

# Función de comportamiento de los agentes
function agent_step!(agent::Robot, model)
    # Obtener celdas adyacentes
    adjacent_positions = nearby_positions(agent, model; moore=true)

    # Sensar el entorno
    surroundings = Dict()
    for pos in adjacent_positions
        if !in_bounds(model.space, pos)
            surroundings[pos] = :wall
        elseif any(a.pos == pos for a in allagents(model))
            surroundings[pos] = :robot
        elseif get_prop(model.space, pos, :box_height, 0) > 0
            surroundings[pos] = :box
        else
            surroundings[pos] = :empty
        end
    end

    # Implementar lógica según la estrategia
    if agent.strategy == 1
        # Estrategia 1: Movimiento aleatorio buscando cajas
        random_movement!(agent, model, surroundings)
    elseif agent.strategy == 2
        # Estrategia 2: Asignación de zonas
        zoned_movement!(agent, model, surroundings)
    elseif agent.strategy == 3
        # Estrategia 3: Cooperación entre robots
        cooperative_movement!(agent, model, surroundings)
    end

    # Actualizar contador de movimientos
    agent.movements += 1
end

# Función de movimiento aleatorio (Estrategia 1)
function random_movement!(agent::Robot, model, surroundings)
    possible_moves = [pos for (pos, status) in surroundings if status == :empty]
    if !agent.has_box
        # Si no lleva caja, buscar una caja cercana
        box_positions = [pos for (pos, status) in surroundings if status == :box]
        if !isempty(box_positions)
            # Recoger caja
            agent.has_box = true
            box_pos = box_positions[1]
            current_height = get_prop(model.space, box_pos, :box_height, 0)
            set_prop!(model.space, box_pos, :box_height, current_height - 1)
            if get_prop(model.space, box_pos, :box_height) == 0
                delete_prop!(model.space, box_pos, :box_height)
            end
            move_agent!(agent, box_pos)
        elseif !isempty(possible_moves)
            # Moverse aleatoriamente
            move_agent!(agent, rand(possible_moves))
        end
    else
        # Si lleva caja, dirigirse a la pared norte
        if agent.pos[2] < 40
            north_pos = (agent.pos[1], agent.pos[2] + 1)
            if get(surroundings, north_pos, :wall) == :empty
                move_agent!(agent, north_pos)
            elseif get(surroundings, north_pos, :box) == :box
                # Apilar caja si la pila tiene menos de 5 cajas
                height = get_prop(model.space, north_pos, :box_height, 0)
                if height < 5
                    agent.has_box = false
                    set_prop!(model.space, north_pos, :box_height, height + 1)
                else
                    # Buscar otra posición
                    if !isempty(possible_moves)
                        move_agent!(agent, rand(possible_moves))
                    end
                end
            else
                # Depositar caja en posición actual si está en la pared norte
                if agent.pos[2] == 40
                    height = get_prop(model.space, agent.pos, :box_height, 0)
                    if height < 5
                        agent.has_box = false
                        set_prop!(model.space, agent.pos, :box_height, height + 1)
                    end
                else
                    # Moverse aleatoriamente
                    if !isempty(possible_moves)
                        move_agent!(agent, rand(possible_moves))
                    end
                end
            end
        else
            # Si ya está en la pared norte
            height = get_prop(model.space, agent.pos, :box_height, 0)
            if height < 5
                agent.has_box = false
                set_prop!(model.space, agent.pos, :box_height, height + 1)
            else
                # Buscar otra posición
                if !isempty(possible_moves)
                    move_agent!(agent, rand(possible_moves))
                end
            end
        end
    end
end

# Puedes implementar las funciones zoned_movement! y cooperative_movement! de manera similar

# Función para actualizar el modelo
function model_step!(model)
    model.properties[:time_steps] += 1
    step!(model, agent_step!)
    # Actualizar movimientos
    total_movements = sum(agent.movements for agent in allagents(model))
    push!(model.properties[:movements], total_movements)
    # Verificar condición de término
    if all_boxes_stacked(model)
        model.stop = true
    end
end

# Función para verificar si todas las cajas están apiladas correctamente
function all_boxes_stacked(model)
    for x in 1:40, y in 1:39  # No es necesario revisar la pared norte
        height = get_prop(model.space, (x, y), :box_height, 0)
        if height > 0
            return false
        end
    end
    # Verificar que las pilas en la pared norte no excedan 5 cajas
    for x in 1:40
        height = get_prop(model.space, (x, 40), :box_height, 0)
        if height > 5
            return false
        end
    end
    return true
end

# Función para obtener el estado del modelo
function get_model_state(model)
    robots = [Dict(
        "id" => agent.id,
        "pos" => agent.pos,
        "has_box" => agent.has_box,
        "movements" => agent.movements
    ) for agent in allagents(model)]

    boxes = []
    for x in 1:40, y in 1:40
        height = get_prop(model.space, (x, y), :box_height, 0)
        if height > 0
            push!(boxes, Dict(
                "pos" => (x, y),
                "height" => height
            ))
        end
    end

    return Dict(
        "robots" => robots,
        "boxes" => boxes,
        "time_steps" => model.properties[:time_steps]
    )
end