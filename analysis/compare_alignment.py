def analyze(label_file, coord_file):
    with open(label_file, 'r') as f:
        labels = [l.strip().split(' ', 1) for l in f]
    with open(coord_file, 'r') as f:
        coords = [l.strip().split(' ') for l in f]

    nodes = []
    for i in range(min(len(labels), len(coords))):
        nodes.append({'name': labels[i][1], 'x': int(coords[i][0]), 'y': int(coords[i][1])})
    
    # Filter for Gen 2 (y=250) and Gen 3 (y=450)
    parents = [n for n in nodes if n['y'] == 250]
    children = [n for n in nodes if n['y'] == 450]
    
    print(f"Parents: {[(p['name'], p['x']) for p in parents]}")
    print(f"Children: {[(c['name'], c['x']) for c in children]}")

print("--- LAST ---")
analyze('analysis/last/labels.txt', 'analysis/last/coords.txt')
print("\n--- STASH ---")
analyze('analysis/stash/labels.txt', 'analysis/stash/coords.txt')
