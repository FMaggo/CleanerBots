from OpenGL.GL import *
from OpenGL.GLU import *
from OpenGL.GLUT import *

import sys
import numpy as np
from OpMat import OpMat
from caja import Caja
import requests

# URL base de la API y obtención de datos
URL_BASE = "http://localhost:8000"
payload = {"dim": [40, 40]}  # Define la dimensión esperada en el servidor
r = requests.post(URL_BASE + "/simulations", json=payload, allow_redirects=False)
datos = r.json()
print(datos)
LOCATION = datos["Location"]
initialX = datos["boxes"][0]["pos"][0]
initialY = datos["boxes"][0]["pos"][1]

# Dimensiones del plano y límites de ejes
X_MIN, X_MAX = -500, 500
Y_MIN, Y_MAX = -500, 500

# Parámetros para el escalado y desplazamiento
scale_factor = 15  # Ajusta según sea necesario
offset_x = 300     # Ajusta para centrar las cajas en la ventana
offset_y = 300     # Ajusta para centrar las cajas en la ventana

# Inicialización de objetos
opmat = OpMat()
cajas = []  

# Crear una instancia de Caja para cada caja recibida del servidor
for box_data in datos["boxes"]:
    caja_obj = Caja(opmat)
    x_pos = box_data["pos"][0] * scale_factor - offset_x
    y_pos = box_data["pos"][1] * scale_factor - offset_y
    caja_obj.update_position(x_pos, y_pos)
    #caja_obj.update_position(box_data["pos"][0] * 20 - 160, box_data["pos"][1] * 20 - 160)
    cajas.append(caja_obj)

def init():
    # Configuración de la ventana de proyección y modelo
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    gluOrtho2D(-450.0, 450.0, -300.0, 300.0)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()
    
    # Configuración de colores y modos de polígono
    glClearColor(0.0, 0.0, 0.0, 0.0)
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)

def Axis():
    glShadeModel(GL_FLAT)
    glLineWidth(3.0)
    
    # Eje X en rojo
    glColor3f(1.0, 0.0, 0.0)
    glBegin(GL_LINES)
    glVertex2f(X_MIN, 0.0)
    glVertex2f(X_MAX, 0.0)
    glEnd()
    
    # Eje Y en verde
    glColor3f(0.0, 1.0, 0.0)
    glBegin(GL_LINES)
    glVertex2f(0.0, Y_MIN)
    glVertex2f(0.0, Y_MAX)
    glEnd()
    glLineWidth(1.0)

def display():
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    Axis()
    glColor3f(1.0, 1.0, 1.0)  # Color blanco

    # Actualizar las posiciones de las cajas
    response = requests.get(URL_BASE + LOCATION)
    datos = response.json()
    boxes_data = datos["boxes"]

    # Asegurarse de que el número de cajas coincide
    if len(cajas) != len(boxes_data):
        print("Número de cajas inconsistente.")
        # Opcionalmente, manejar este caso reconstruyendo la lista de cajas

    for caja_obj, box_data in zip(cajas, boxes_data):
        x_pos = box_data["pos"][0] * scale_factor - offset_x
        y_pos = box_data["pos"][1] * scale_factor - offset_y
        caja_obj.update_position(x_pos, y_pos)
        caja_obj.render()

    glutSwapBuffers()

def timer(value):
    glutPostRedisplay()
    glutTimerFunc(16, timer, 0)  # Aproximadamente 60 FPS


if __name__ == "__main__":
    glutInit(sys.argv)
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB)
    glutInitWindowSize(900, 600)
    glutInitWindowPosition(100, 100)
    glutCreateWindow("Robots")
    init()  # Llamada a la función de inicialización
    glutDisplayFunc(display)  # Configuración de la función de display
    glutTimerFunc(0, timer, 0)  # Iniciar la función del temporizador
    glutMainLoop()