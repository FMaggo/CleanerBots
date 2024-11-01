include("simple.jl")
using Genie, Genie.Renderer.Json, Genie.Requests, HTTP
using UUIDs
using StatsBase

instances = Dict()

route("/simulations", method = POST) do
    payload = jsonpayload()
    x = payload["dim"][1]
    y = payload["dim"][2]

    # Inicializar el modelo
    model = initialize_model((x,y))
    id = string(uuid1())
    instances[id] = model

    robots = []
    for agent in allagents(model)
        if agent isa Robot
            push!(robots, agent)
        end
    end

    boxes = []
    for box in allagents(model)
        push!(boxes, Dict("id" => box.id, "pos" => box.pos))
    end

    json(Dict(
        "Location" => "/simulations/$id",
        "robots" => robots,
        "boxes" => boxes
    ))
end

route("/simulations/:id") do
    model = instances[payload(:id)]
    run!(model, 1)

    robots = []
    for agent in allagents(model)
        if agent isa Robot
            push!(robots, agent)
        end
    end

    boxes = []
    for box in allagents(model)
        push!(boxes, Dict("id" => box.id, "pos" => box.pos))
    end

    json(Dict("message" => "Simulation updated",
        "robots" => robots,
        "boxes" => boxes
    ))
end

Genie.config.run_as_server = true
Genie.config.cors_headers["Access-Control-Allow-Origin"] = "*"
Genie.config.cors_headers["Access-Control-Allow-Headers"] = "Content-Type"
Genie.config.cors_headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS"
Genie.config.cors_allowed_origins = ["*"]

up()
