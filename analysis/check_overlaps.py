import re

rects = []
pattern = re.compile(r'x="(\d+)" y="(\d+)" width="(\d+)" height="(\d+)"')

with open('rects.txt', 'r') as f:
    for line in f:
        # Skip the SVG background container
        if 'width="100%"' in line:
            continue
            
        match = pattern.search(line)
        if match:
            x, y, w, h = map(int, match.groups())
            rects.append({'x': x, 'y': y, 'w': w, 'h': h, 'line': line.strip()})

def overlaps(r1, r2):
    # Standard AABB overlap check (including touching)
    return not (r1['x'] >= r2['x'] + r2['w'] or
                r1['x'] + r1['w'] <= r2['x'] or
                r1['y'] >= r2['y'] + r2['h'] or
                r1['y'] + r1['h'] <= r2['y'])

collisions = []
for i in range(len(rects)):
    for j in range(i + 1, len(rects)):
        if overlaps(rects[i], rects[j]):
            collisions.append((rects[i], rects[j]))

if collisions:
    print(f"Found {len(collisions)} collisions/overlaps:")
    for r1, r2 in collisions:
        print(f"Collision between:\n  {r1['line']}\n  {r2['line']}")
else:
    print("No overlaps or touching rectangles found.")
