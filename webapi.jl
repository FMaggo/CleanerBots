include("simple.jl")
using Genie, Genie.Renderer.Json, Genie.Requests, HTTP
using UUIDs

instances = Dict()

route("/simulations", method = POST) do
    payload = jsonpayload()

    # Inicializar el modelo
    model = initialize_model()
    id = string(uuid1())
    instances[id] = model

    # Recolectar coches (solo agentes de tipo Car)
    cars = []
    for agent in allagents(model)
        if agent isa Car
            push!(cars, agent)
        end
    end

    # Recolectar semáforos
    trafficLights = []
    for agent in allagents(model)
        if agent isa Semaforo
            push!(trafficLights, Dict(
                "id" => agent.id,
                "pos" => agent.pos,
                "state" => agent.state,
                "timer" => agent.timer
            ))
        end
    end

    # Devolver la ubicación, coches y semáforos
    json(Dict(
        "Location" => "/simulations/$id",
        "cars" => cars,
        "trafficLights" => trafficLights
    ))
end

route("/simulations/:id") do
    model = instances[payload(:id)]
    run!(model, 1)

    # Recolectar coches (solo agentes de tipo Car)
    cars = []
    for agent in allagents(model)
        if agent isa Car
            push!(cars, agent)
        end
    end

    # Recolectar semáforos
    trafficLights = []
    for agent in allagents(model)
        if agent isa Semaforo
            push!(trafficLights, Dict(
                "id" => agent.id,
                "pos" => agent.pos,
                "state" => agent.state,
                "timer" => agent.timer
            ))
        end
    end

    # Devolver los coches y semáforos
    json(Dict(
        "cars" => cars,
        "trafficLights" => trafficLights
    ))
end

Genie.config.run_as_server = true
Genie.config.cors_headers["Access-Control-Allow-Origin"] = "*"
Genie.config.cors_headers["Access-Control-Allow-Headers"] = "Content-Type"
Genie.config.cors_headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS"
Genie.config.cors_allowed_origins = ["*"]

up()