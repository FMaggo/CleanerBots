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

function agent_step!(agent::Robot, model)
    possible_moves = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    current_pos = agent.pos
    if agent.carrying_box == false
        for other in nearby_agents(agent, model,1)
            if other isa Box && other.box_count == 1 && other.pos[2] != 40
                agent.pos = other.pos
                agent.carrying_box = true
                remove_agent!(other, model)
                break
            elseif other isa Robot && agent.id > other.id
                # prioridad por id
                opposite_direction = -1 .* (agent.pos .- other.pos)
                new_pos = agent.pos .+ opposite_direction
                move_agent!(agent, new_pos, model)
                break
            elseif other isa Robot && agent.id < other.id
                current_pos = agent.pos
                break
            end
        end
    elseif agent.carrying_box == true
        for other_agent in nearby_agents(agent,model,1)
            if other_agent isa Box
                for move in possible_moves
                    new_pos = current_pos .+ move
                    if is_empty_space(new_pos, model)
                        move_agent!(agent, new_pos, model)
                        break
                    end
                end
            elseif other_agent isa Robot && agent.id > other_agent.id
                # prioridad por id
                opposite_direction = -1 .* (agent.pos .- other.pos)
                new_pos = agent.pos .+ opposite_direction
                move_agent!(agent, new_pos, model)
                break
            elseif other_agent isa Robot && agent.id < other_agent.id
                current_pos = agent.pos
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
        add_agent!(pos, Box, model; box_count = 1)
    end

    available_positions = setdiff(all_positions, selected_positions)
    robot_positions = available_positions[1:5]
    for pos in robot_positions
        add_agent!(pos, Robot, model; carrying_box = false)
    end

    return model
end