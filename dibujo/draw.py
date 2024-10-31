from OpenGL.GL import *
def draw_line(p1, p2):
    x0, y0 = int(round(p1[0])), int(round(p1[1]))
    x1, y1 = int(round(p2[0])), int(round(p2[1]))

    dx = abs(x1 - x0)
    dy = abs(y1 - y0)
    x, y = x0, y0
    sx = -1 if x0 > x1 else 1
    sy = -1 if y0 > y1 else 1

    glBegin(GL_POINTS)
    if dx > dy:
        err = dx / 2.0
        while x != x1:
            glVertex2i(x, y)
            err -= dy
            if err < 0:
                y += sy
                err += dx
            x += sx
        glVertex2i(x, y)  # Draw the last point
    else:
        err = dy / 2.0
        while y != y1:
            glVertex2i(x, y)
            err -= dx
            if err < 0:
                x += sx
                err += dy
            y += sy
        glVertex2i(x, y)  # Draw the last point
    glEnd()