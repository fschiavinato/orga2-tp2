import csv
import math
import matplotlib.pyplot as plt
import numpy as np

with open('constante_ldr_c_avg.csv', 'r') as csvfile:
    xAxis = [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000]
    values = []
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        values.append(row[:10])
    values = np.array(values).astype(np.float)
    plt.pcolormesh(xAxis, xAxis, values)
    plt.colorbar()
    plt.xlabel("Ancho (px)")
    plt.ylabel("Alto (px)")
    plt.title("Constante C")
    plt.show()
