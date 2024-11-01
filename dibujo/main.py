import pygame
from OpenGL.GL import *
from OpenGL.GLU import *
import sys
import requests
from OpMat import OpMat
from caja import Caja
from robot import Robot

# URL base de la API y obtención de datos
URL_BASE = "http://localhost:8000"
payload = {"dim": [40, 40]}  # Define la dimensión esperada en el servidor
r = requests.post(URL_BASE + "/simulations", json=payload, allow_redirects=False)
datos = r.json()
print("Datos iniciales:", datos)

LOCATION = datos["Location"]

# Dimensiones del plano y límites de ejes
X_MIN, X_MAX = -450, 450
Y_MIN, Y_MAX = -450, 450

# Inicialización de objetos
opmat = OpMat()
cajas_normales = []  # Lista de cajas que no son robots
robots = []          # Lista de robots

# Crear instancias de Caja y Robot según los datos recibidos
for box_data in datos["boxes"]:
    caja_obj = Caja(opmat)
    x_pos = box_data["pos"][0] * 20 - 400
    y_pos = box_data["pos"][1] * 20 - 400
    caja_obj.update_position(x_pos, y_pos)
    cajas_normales.append(caja_obj)

for robot_data in datos["robots"]:
    robot_obj = Robot(opmat)  # Crear una instancia de Robot
    x_pos = (robot_data["pos"][0] - 1) * 20 - 400
    y_pos = (40 - robot_data["pos"][1]) * 20 - 400
    robot_obj.update_position(x_pos, y_pos)
    robots.append(robot_obj)

def init():
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    gluOrtho2D(X_MIN, X_MAX, Y_MIN, Y_MAX)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()
    glClearColor(0.0, 0.0, 0.0, 0.0)
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)

def update_simulation_state():
    global cajas_normales, robots
    # Solicitar estado actualizado del servidor
    try:
        r = requests.get(URL_BASE + LOCATION)
        data = r.json()

        # Actualizar posiciones de las cajas
        #for i, box_data in enumerate(data["boxes"]):
            #x_pos = box_data["pos"][0] * 20 - 400
            #y_pos = box_data["pos"][1] * 20 - 400
            #if i < len(cajas_normales):
                #cajas_normales[i].update_position(x_pos, y_pos)

        # Actualizar posiciones de los robots
        for i, robot_data in enumerate(data["robots"]):
            x_pos = (robot_data["pos"][0] - 1) * 20 - 400
            y_pos = (40 - robot_data["pos"][1]) * 20 - 400
            if i < len(robots):
                robots[i].update_position(x_pos, y_pos)

    except requests.exceptions.RequestException as e:
        print(f"Error al actualizar el estado de la simulación: {e}")

def display():
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    # Dibujar todas las cajas normales en blanco
    for caja_obj in cajas_normales:
        caja_obj.render()  # Blanco por defecto

    # Dibujar los robots en rojo
    for robot_obj in robots:
        robot_obj.render(color=(1.0, 0.0, 0.0))

if __name__ == "__main__":
    # Inicializar pygame y configurar la ventana OpenGL
    pygame.init()
    screen = pygame.display.set_mode((600, 600), pygame.DOUBLEBUF | pygame.OPENGL)
    pygame.display.set_caption("Robots y Cajas")
    init()

    # Main loop
    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
                pygame.quit()
                sys.exit()

        # Actualizar el estado de la simulación obteniendo datos del servidor
        update_simulation_state()

        # Llamar a la función de renderizado para actualizar la visualización
        display()

        # Intercambiar buffers y esperar para mantener la tasa de FPS (~60 FPS)
        pygame.display.flip()
        pygame.time.wait(500)  # Ajusta el intervalo de espera para sincronizar con las actualizaciones