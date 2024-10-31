from OpenGL.GL import *
from draw import draw_line

class Caja:
    def __init__(self, opmat, width=20, height=20):
        self.opmat = opmat  # Reference to the OpMat object
        w = width / 2.0
        h = height / 2.0
        self.position = [0, 0]
        self.base_points = [(-w, -h), (w, -h), (w, h), (-w, h)]  # Rectangle corners

    def update_position(self, x, y):
        """Update the position of the box to a new x, y coordinate."""
        self.position = [x, y]

    def render(self):
        # Aplicar la máquina de estados de OpenGL para transformar la posición
        glPushMatrix()  # Guardar el estado actual de OpenGL
        glTranslatef(self.position[0], self.position[1], 0)  # Trasladar a la posición de la caja

        transformed_points = self.opmat.mult_points(self.base_points)
        
        # Dibujar el rectángulo conectando los puntos transformados
        draw_line(transformed_points[0], transformed_points[1])
        draw_line(transformed_points[1], transformed_points[2])
        draw_line(transformed_points[2], transformed_points[3])
        draw_line(transformed_points[3], transformed_points[0])
        
        glPopMatrix()  # Restaurar el estado de OpenGL al estado anterior