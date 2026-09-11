import re

# Standard spacing from family_constants.rb
SIBLING_SPACING = 150
THRESHOLD = SIBLING_SPACING * 2

rects = []
# Match rect tags and capture attributes
pattern = re.compile(r'<rect x="(\d+)" y="(\d+)" width="(\d+)" height="(\d+)"')

with open('rects.txt', 'r') as f:
    for line in f:
        if 'width="100%"' in line:
            continue
            
        match = pattern.search(line)
        if match:
            x, y, w, h = map(int, match.groups())
            rects.append({'x': x, 'y': y, 'w': w, 'h': h})

# Group by y-level
levels = {}
for r in rects:
    levels.setdefault(r['y'], []).append(r)

# Analyze gaps
print(f"Searching for gaps > {THRESHOLD} (Sibling spacing: {SIBLING_SPACING})")
for y, level_rects in levels.items():
    level_rects.sort(key=lambda r: r['x'])
    
    for i in range(len(level_rects) - 1):
        r1 = level_rects[i]
        r2 = level_rects[i+1]
        gap = r2['x'] - (r1['x'] + r1['w'])
        if gap > THRESHOLD:
            print(f"Level {y}: Large gap of {gap} between x={r1['x']+r1['w']} and x={r2['x']}")
