using Agents, Random
@agent struct Robot(GridAgent{2, Float64})
    carrying_box::Bool = false
    #orientation::Symbol = :north
    #last_direction::Symbol
end

@agent struct Box(GridAgent{2, Float64})
    box_count::Int
end

#directions = Dict(:north => (0, 1), :south => (0, -1), :east => (1, 0), :west => (-1, 0))
#opposite_direction = Dict(:north => :south, :south => :north, :east => :west, :west => :east)
function agent_step!(agent::Box, model)
end

function agent_step!(agent::Robot, model)
    print(".")
    possible_moves = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    current_pos = agent.pos
    #Si no encuentra agente cercano, se mueve de manera aleatoria
    shuffle!(possible_moves)
        for move in possible_moves
            new_pos = current_pos .+ move
            move_agent!(agent, new_pos, model)
        end
    #Cuando el robot no lleva una caja y encuentra otros agentes
    if agent.carrying_box == false
        for other in nearby_agents(agent, model,1)
            #Si no se lleva caja y se encuentra una, el robot toma su posicion y la agarra
            if other isa Box && other.box_count == 1 && other.pos[2] != 40
                agent.carrying_box = true
                remove_agent!(other, model)
                agent.pos = other.pos
                new_pos = agent.pos .+ (0,1)
                move_agent!(agent, new_pos, model)
            #Si encuentra un robot con id menor, el agente se mueve en la direccion contraria
            elseif other isa Robot && agent.id > other.id
                opposite_direction = -1 .* (agent.pos .- other.pos)
                new_pos = agent.pos .+ opposite_direction
                move_agent!(agent, new_pos, model)
            #Si encuentra un robot con id mayor, el robot se queda en su posicion
            elseif other isa Robot && agent.id < other.id
                current_pos = agent.pos
            end
        end
    #Cuando el robot lleva una caja y no ha llegado a la pared norte
    elseif agent.carrying_box == true && agent.pos[2] != 40
        #Si no hay agente cercano, se mueve hacia arriba
        new_pos = agent.pos .+ (0,1)
        move_agent!(agent, new_pos, model) 
        for other_agent in nearby_agents(agent,model,1)
            #Si encuentra una caja, la ignora y se mueve a una posicion libre
            if other_agent isa Box
                opposite_direction = -1 .* (agent.pos .- other.pos)
                new_pos = agent.pos .+ opposite_direction
                move_agent!(agent, new_pos, model)
            #Si encuentra un robot con id menor, el agente se mueve en la direccion contraria
            elseif other_agent isa Robot && agent.id > other_agent.id
                opposite_direction = -1 .* (agent.pos .- other.pos)
                new_pos = agent.pos .+ opposite_direction
                move_agent!(agent, new_pos, model)
            #Si encuentra un robot con id mayor, el robot se queda en su posicion
            elseif other_agent isa Robot && agent.id < other_agent.id
                current_pos = agent.pos
            end
        end
    elseif agent.carrying_box == true && agent.pos[2] == 40
        #Si no hay agente cercano, se mueve hacia abajo
            new_pos = current_pos .+ (0,-1)
            move_agent!(agent, new_pos, model)
        for agent in nearby_agents(agent, model, 1)
            if agent isa Box && agent.box_count 
            agent.carrying_box = false
            #add_agent!(Box, agent.pos, box_count = 1, model)
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