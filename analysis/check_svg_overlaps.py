import re
import sys

def check_overlaps(svg_path):
    rects = []
    pattern = re.compile(r'x="([\d\.-]+)"\s+y="([\d\.-]+)"\s+width="([\d\.-]+)"\s+height="([\d\.-]+)"')
    
    with open(svg_path, 'r') as f:
        for line in f:
            if 'width="100%"' in line or 'width="100%\"' in line:
                continue
            for match in pattern.finditer(line):
                x, y, w, h = map(float, match.groups())
                rects.append({'x': x, 'y': y, 'w': w, 'h': h, 'line': line.strip()})

    def overlaps(r1, r2):
        return not (r1['x'] >= r2['x'] + r2['w'] or
                    r1['x'] + r1['w'] <= r2['x'] or
                    r1['y'] >= r2['y'] + r2['h'] or
                    r1['y'] + r1['h'] <= r2['y'])

    collisions = []
    for i in range(len(rects)):
        for j in range(i + 1, len(rects)):
            if overlaps(rects[i], rects[j]):
                collisions.append((rects[i], rects[j]))

    print(f"File: {svg_path}")
    print(f"Total rects found: {len(rects)}")
    if collisions:
        print(f"Found {len(collisions)} collisions/overlaps:")
        for r1, r2 in collisions:
            print(f"  Collision between:\n    {r1['line']}\n    {r2['line']}")
    else:
        print("No overlaps or collisions found.")
    return len(collisions)

if __name__ == '__main__':
    if len(sys.argv) > 1:
        for path in sys.argv[1:]:
            check_overlaps(path)
    else:
        print("Usage: python3 check_svg_overlaps.py <svg_file>")
