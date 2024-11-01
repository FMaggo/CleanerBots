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

    def render(self, color=(1.0, 1.0, 1.0)):
        """
        Render the box with the specified color.
        
        Parameters:
        color (tuple): RGB color to use for the box (default is white).
        """
        glPushMatrix()  # Save the current OpenGL state
        glTranslatef(self.position[0], self.position[1], 0)  # Translate to the box position

        glColor3f(*color)  # Set the color
        transformed_points = self.opmat.mult_points(self.base_points)
        
        # Draw the rectangle by connecting the transformed points
        draw_line(transformed_points[0], transformed_points[1])
        draw_line(transformed_points[1], transformed_points[2])
        draw_line(transformed_points[2], transformed_points[3])
        draw_line(transformed_points[3], transformed_points[0])
        
        glPopMatrix()  # Restore the previous OpenGL state