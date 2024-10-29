    
include("simple.jl")  

using Genie, Genie.Renderer.Json, Genie.Requests, HTTP
using UUIDs
using StatsBase

# Diccionario para almacenar instancias de modelos
instances = Dict()

# Ruta para crear una nueva simulación
route("/simulations", method = POST) do
    payload = jsonpayload()
    x = payload["dim"][1]
    y = payload["dim"][2]

    # Inicializar el modelo con el número de cajas en la cuadrícula
    model = position_Boxes((x, y))
    id = string(uuid1())
    instances[id] = model

    # Recopilar las posiciones iniciales de cada caja
    boxes = []
    for box in allagents(model)
        push!(boxes, Dict("id" => box.id, "pos" => box.pos))
    end
    
    json(Dict("message" => "Simulation started", "Location" => "/simulations/$id", "boxes" => boxes))
end

# Ruta para avanzar en la simulación y obtener el nuevo estado
route("/simulations/:id") do
    model = instances[payload(:id)]
    run!(model, 1)  # Ejecutar un paso de la simulación
    boxes = []
    for box in allagents(model)
        push!(boxes, Dict("id" => box.id, "pos" => box.pos))
    end
    
    json(Dict("message" => "Simulation updated", "boxes" => boxes))
end

# Configuración de CORS
Genie.config.run_as_server = true
Genie.config.cors_headers["Access-Control-Allow-Origin"] = "*"
Genie.config.cors_headers["Access-Control-Allow-Headers"] = "Content-Type"
Genie.config.cors_headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS"
Genie.config.cors_allowed_origins = ["*"]

# Iniciar el servidor
up()
