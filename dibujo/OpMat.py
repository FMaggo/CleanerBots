import numpy as np

class OpMat:
    def __init__(self):
        self.A = np.identity(3)  # Transformation matrix
        self.stack = []  # Stack for Push and Pop operations

    def translate(self, tx, ty):
        T = np.array([
            [1, 0, tx],
            [0, 1, ty],
            [0, 0, 1]
        ])
        self.A = np.dot(self.A, T)

    def rotate(self, angle):
        rad = np.deg2rad(angle)
        R = np.array([
            [np.cos(rad), -np.sin(rad), 0],
            [np.sin(rad),  np.cos(rad), 0],
            [0, 0, 1]
        ])
        self.A = np.dot(self.A, R)

    def scale(self, sx, sy):
        S = np.array([
            [sx, 0, 0],
            [0, sy, 0],
            [0, 0, 1]
        ])
        self.A = np.dot(self.A, S)

    def push(self):
        self.stack.append(self.A.copy())

    def pop(self):
        if self.stack:
            self.A = self.stack.pop()
        else:
            print("The stack is empty!")

    def mult_points(self, points):
        # 'points' is a list of [x, y]
        transformed_points = []
        for point in points:
            p = np.array([point[0], point[1], 1])
            p_transformed = np.dot(self.A, p)
            transformed_points.append([p_transformed[0], p_transformed[1]])
        return transformed_points