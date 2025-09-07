import pandas as pd

# Specify the path to the CSV file
csv_file = '/path/to/cars_dataset.csv'

# Load the dataset into a pandas DataFrame
df = pd.read_csv(csv_file)

# Print the first few rows of the DataFrame
print(df.head())

## plot all columns against each other as pair plots
from time import sleep, perf_counter as pc

@timebudget
def fib(n):
    if n <= 1:
        return n
    else:
        return fib(n-1) + fib(n-2)

import numba as nb
@nb.njit
def fib_jit(n):
    if n <= 1:
        return n
    else:
        return fib(n-1) + fib(n-2)

t0 = pc()
print(fib(40))
print(pc()-t0)

t1 = pc()
print(fib_jit(40))
print(pc()-t1)


from numba import jit
import numpy as np
import time

x = np.arange(100).reshape(10, 10)

@jit(nopython=True)
def go_fast(a): # Function is compiled and runs in machine code
    trace = 0.0
    for i in range(a.shape[0]):
        trace += np.tanh(a[i, i])
    return a + trace

# DO NOT REPORT THIS... COMPILATION TIME IS INCLUDED IN THE EXECUTION TIME!
start = time.time()
go_fast(x)
end = time.time()
print("Elapsed (with compilation) = %s" % (end - start))

# NOW THE FUNCTION IS COMPILED, RE-TIME IT EXECUTING FROM CACHE
start = time.time()
go_fast(x)
end = time.time()
print("Elapsed (after compilation) = %s" % (end - start))



import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpec

# Define the main color palette
colors = {
    'Africa': '#8c564b', 'North Europe': '#1f77b4', 'South Europe': '#2ca02c',
    'West Europe': '#ff7f0e', 'Pacific America': '#d62728',
    'Chinese': '#9467bd', 'Asian': '#17becf', 'Pakistani': '#e377c2',
    'Indian': '#bcbd22', 'Mixed': '#7f7f7f', 'Other': '#c7c7c7'
}

# Create the figure and the main axis
fig = plt.figure(figsize=(18, 12))
gs = GridSpec(3, 3, figure=fig, width_ratios=[1, 3, 1])

# Title and Subtitle
fig.suptitle('Global Ancestry Patterns in Asia and Africa', fontsize=24, fontweight='bold')
fig.text(0.5, 0.94, 'A Comprehensive Genetic Diversity Analysis', ha='center', fontsize=18)

# Main map
ax_map = fig.add_subplot(gs[0:2, 1])
ax_map.axis('off')  # No axis for the map

# Insert map drawing code here...

# Ancestry Graphs
# Define positions and dimensions
graph_positions = {
    'Turkey': (0, 0), 'Iraq': (0, 1), 'Iran': (0, 2), 'Afghanistan': (1, 0), 'Pakistan': (1, 1),
    'Nepal': (1, 2), 'Japan': (2, 0), 'China': (2, 1), 'Hong Kong': (2, 2)
}

for region, pos in graph_positions.items():
    ax = fig.add_subplot(gs[pos[0], pos[1]])
    ax.set_title(region, fontsize=12)
    # Insert ancestry data plotting code here...

# Adjust layout
plt.tight_layout(rect=[0, 0, 1, 0.9])

# Save or display the figure
plt.show()
