with open('analysis/labels_clean.txt', 'r') as f:
    labels = [line.strip().split(' ', 1) for line in f]
with open('analysis/coords_clean.txt', 'r') as f:
    coords = [line.strip().split(' ') for line in f]

node_map = {}
for i in range(min(len(labels), len(coords))):
    node_id = labels[i][1]
    node_map[node_id] = (int(coords[i][0]), int(coords[i][1]))

collisions = {}
for name, pos in node_map.items():
    if pos not in collisions:
        collisions[pos] = []
    collisions[pos].append(name)

for pos, names in collisions.items():
    if len(names) > 1:
        print(f"Collision at {pos}: {names}")
