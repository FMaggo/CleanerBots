using Agents, Random
using StaticArrays: SVector

@agent struct Car(ContinuousAgent{2, Float64})
    accelerating::Bool = true
    current_speed::Float64
    acceleration::Float64
    deceleration::Float64
    max_speed::Float64
    direction::Symbol
end

@agent struct Semaforo(ContinuousAgent{2, Float64})
    state::Symbol = :green
    timer::Int = 0
    orientation::Symbol
end

# Definir la lógica de los agentes
function agent_step!(agent::Semaforo, model)
    agent.timer += 1
    if agent.state == :green && agent.timer >= 10
        agent.state = :yellow
        agent.timer = 0
    elseif agent.state == :yellow && agent.timer >= 4
        agent.state = :red
        agent.timer = 0
    elseif agent.state == :red && agent.timer >= 14
        agent.state = :green
        agent.timer = 0
    end
end

function agent_step!(agent::Car, model)
    # Verificar si está detenido y si el semáforo está en verde
    for other in nearby_agents(agent, model, 2.0)
        if other isa Semaforo && other.orientation == agent.direction
            # Si el semáforo está en rojo o amarillo y está cerca, detener el coche
            if (other.state == :red || other.state == :yellow) && abs(agent.pos[1] - other.pos[1]) <= 2.0
                agent.accelerating = false  # Detener el coche
            # Si el semáforo está en verde, permitir que el coche acelere nuevamente
            elseif other.state == :green && abs(agent.pos[1] - other.pos[1]) <= 2.0
                agent.accelerating = true  # Reanudar la aceleración
            end
        end
    end

    for other_car in allagents(model)
        if other_car isa Car && other_car.id != agent.id && other_car.direction == agent.direction
            if agent.direction == :horizontal
                # Para dirección horizontal, verificar si otro coche está adelante en x
                if other_car.pos[2] == agent.pos[2]  # Misma calle vertical
                    distance = other_car.pos[1] - agent.pos[1]
                    if distance > 0 && distance <= 2.0
                        agent.accelerating = false
                        break  # No es necesario seguir buscando
                    end
                end
            elseif agent.direction == :vertical
                # Para dirección vertical, verificar si otro coche está adelante en y
                if other_car.pos[1] == agent.pos[1]  # Misma calle horizontal
                    distance = other_car.pos[2] - agent.pos[2]
                    if distance > 0 && distance <= 2.0
                        agent.accelerating = true
                        break  # No es necesario seguir buscando
                    end
                end
            end
        end
    end

    # Mover el coche si está acelerando
    if agent.accelerating == false
        # Desacelerar
        agent.current_speed = max(agent.current_speed - agent.deceleration, 0.0)
    else
        # Acelerar
        agent.current_speed = min(agent.current_speed + agent.acceleration, agent.max_speed)
    end

    # Actualizar posición según la dirección y la velocidad actual
    if agent.direction == :horizontal
        agent.pos = (agent.pos[1] + agent.current_speed, agent.pos[2])
    elseif agent.direction == :vertical
        agent.pos = (agent.pos[1], agent.pos[2] + agent.current_speed)
    end

    # Comprobar si el coche salió del límite y hacer que aparezca en el otro lado
    if agent.direction == :horizontal
        if agent.pos[1] > 25.0  # Ajusta el valor según tu mapa
            agent.pos = (1.0, agent.pos[2])  # Aparece en el lado izquierdo
        end
    elseif agent.direction == :vertical
        if agent.pos[2] > 25.0
            agent.pos = (agent.pos[1], 1.0)
        end
    end
end

function initialize_model()
    # Crear el modelo de agente con ambos tipos
    shuffle_types = false
    shuffle_agents = false
    model = ABM(Union{Semaforo, Car}; scheduler = Schedulers.ByType((Semaforo, Car), shuffle_agents::Bool), agent_step! = agent_step!)

    # Agregar semáforos con orientación
    add_agent!(Semaforo(1, (11.3, 12.0), (0.0, 0.0), :green, 0, :horizontal), model)
    add_agent!(Semaforo(2, (12.5, 10.0), (0.0, 0.0), :red, 0, :vertical), model)

    current_speed = 0.0
    acceleration = 0.1      # Unidades por paso^2
    deceleration = 0.2      # Unidades por paso^2
    max_speed = 1.0         # Unidades por paso

    # Agregar un coche con dirección horizontal
    horizontal_cars = [
    Car(3, SVector(1.0, 12.0), SVector(0.0, 0.0), true, current_speed, acceleration, deceleration, max_speed, :horizontal),
    Car(4, SVector(5.0, 12.0), SVector(0.0, 0.0), true, current_speed, acceleration, deceleration, max_speed, :horizontal),
    Car(5, SVector(9.0, 12.0), SVector(0.0, 0.0), true, current_speed, acceleration, deceleration, max_speed, :horizontal)
    ]
    for car in horizontal_cars
        add_agent!(car, model)
    end

    # Agregar tres coches en la calle vertical
    vertical_cars = [
    Car(6, SVector(12.0, 1.0), SVector(0.0, 0.0), true, current_speed, acceleration, deceleration, max_speed, :vertical),
    Car(7, SVector(12.0, 5.0), SVector(0.0, 0.0), true, current_speed, acceleration, deceleration, max_speed, :vertical),
    Car(8, SVector(12.0, 9.0), SVector(0.0, 0.0), true, current_speed, acceleration, deceleration, max_speed, :vertical)
    ]
    for car in vertical_cars
        add_agent!(car, model)
    end

    return model
end