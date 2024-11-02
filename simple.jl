using Agents, Random
@agent struct Robot(GridAgent{2, Float64})
    carrying_box::Bool = false
    #orientation::Symbol = :north
    #last_direction::Symbol
end

@agent struct Box(GridAgent{2, Float64})
    box_count::Int
end

directions = Dict(:north => (0, 1), :south => (0, -1), :east => (1, 0), :west => (-1, 0))
opposite_direction = Dict(:north => :south, :south => :north, :east => :west, :west => :east)

max_x, max_y = model.griddims

function agent_step!(agent::Box, model)
end

#agent.orientation = :north
#agent.directions[directions], model 
#relative directions

function agent_step!(agent::Robot, model)
    print(".")
    possible_moves = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    if !agent.carrying_box
        # Si el robot no lleva una caja
        shuffle!(possible_moves)
        
        for move in possible_moves
            new_pos = agent.pos .+ move
            move_agent!(agent, new_pos, model)
        end
        
        for other in nearby_agents(agent, model, 1)
            # Si encuentra una caja, la recoge y la elimina del mapa
            if other isa Box && other.pos[2] != 40
                agent.carrying_box = true
                agent.pos = other.pos
                remove_agent!(other, model)  # Eliminar caja correctamente
                break
            # Si encuentra un robot de menor id, se mueve en dirección contraria
            elseif other isa Robot && agent.id > other.id
                opposite_move = -1 .* (agent.pos .- other.pos)
                new_pos = agent.pos .+ opposite_move
                move_agent!(agent, new_pos, model)
                break
            end
        end
        
    elseif agent.carrying_box && agent.pos[2] < 40
        # Si lleva una caja y no ha llegado a la pared norte
        new_pos = agent.pos .+ (0, 1)
        move_agent!(agent, new_pos, model)
        
        for other in nearby_agents(agent, model, 1)
            # Ignora las cajas mientras lleva otra
            if other isa Box
                continue
            # Si encuentra un robot de menor id, se mueve en dirección contraria
            elseif other isa Robot && agent.id > other.id
                opposite_move = -1 .* (agent.pos .- other.pos)
                new_pos = agent.pos .+ opposite_move
                move_agent!(agent, new_pos, model)
                break
            end
        end

    elseif agent.carrying_box && agent.pos[2] == 40
        # Si ha llegado a la pared norte
        agent.carrying_box = false  # Deja la caja
        for other in nearby_agents(agent, model, 1)
            if other isa Box && other.pos[2] == 40 && other.box_count < 5
                other.box_count += 1  # Apilar en la caja existente
                break
            else
                add_agent!(Box, agent.pos, model, box_count=1)  # Crear nueva pila
                break
            end
        end
    end
end

function initialize_model(griddims = (40, 40), max_boxes = 40)
    space = GridSpace(griddims; periodic=false, metric = :manhattan)
    model = ABM(
        Union{Box, Robot}, 
        space, 
        scheduler = Schedulers.ByType(true, true, Union{Box, Robot}), 
        agent_step! = agent_step!)
    all_positions = [pos for pos in positions(model) if pos[2] <= griddims[2] - 3]
    shuffled_positions = shuffle!(all_positions)

    selected_positions = shuffled_positions[1:min(max_boxes, length(shuffled_positions))]
    for pos in selected_positions
        add_agent!(Box, model; pos=pos,box_count = 1)
    end

    available_positions = setdiff(all_positions, selected_positions)
    robot_positions = available_positions[1:5]
    for pos in robot_positions
        add_agent!(Robot, model; pos=pos, carrying_box = false)
    end
    return model
end