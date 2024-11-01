from OpenGL.GL import *
from caja import Caja

class Robot:
    def __init__(self, opmat):
        self.opmat = opmat
        self.body = Caja(opmat, width=30, height=40)  # Cuerpo del robot
        self.antenna1 = Caja(opmat, width=2, height=15)  # Antena izquierda
        self.antenna2 = Caja(opmat, width=2, height=15)  # Antena derecha
        self.position = [0, 0]  # Posición inicial del robot
        self.angle = 0  # Ángulo de rotación

    def update_position(self, x, y):
        """Actualizar la posición del robot a nuevas coordenadas x, y."""
        self.position = [x, y]

    def render(self, color=(1.0, 0.0, 0.0)):  # Color rojo por defecto
        self.opmat.push()
        self.opmat.translate(self.position[0], self.position[1])
        self.opmat.rotate(self.angle)

        # Dibujar el cuerpo del robot con el color especificado
        self.body.render(color=color)

        # Dibujar la antena izquierda con el mismo color
        self.opmat.push()
        self.opmat.translate(-10, 20)  # Posición relativa al cuerpo del robot
        self.antenna1.render(color=color)
        self.opmat.pop()

        # Dibujar la antena derecha con el mismo color
        self.opmat.push()
        self.opmat.translate(10, 20)  # Posición relativa al cuerpo del robot
        self.antenna2.render(color=color)
        self.opmat.pop()

        self.opmat.pop()