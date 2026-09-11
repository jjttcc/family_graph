import re
import sys

# Pattern for SVG viewport
viewport_pattern = re.compile(r'<svg width="(\d+)" height="(\d+)"')
# Pattern for rect node
rect_pattern = re.compile(r'<rect x="(\d+)" y="(\d+)" width="(\d+)" height="(\d+)"')

def check_bounds(svg_path):
    with open(svg_path, 'r') as f:
        content = f.read()

    viewport_match = viewport_pattern.search(content)
    if not viewport_match:
        print("Could not find SVG viewport dimensions.")
        return
    
    svg_w, svg_h = map(int, viewport_match.groups())
    print(f"SVG Viewport: {svg_w}x{svg_h}")

    rects = rect_pattern.findall(content)
    out_of_bounds = []
    
    min_x = float('inf')
    max_x = float('-inf')

    for r in rects:
        x, y, w, h = map(int, r)
        min_x = min(min_x, x)
        max_x = max(max_x, x + w)
        # Check if rect is completely outside or clipped
        if x < 0 or y < 0 or (x + w) > svg_w or (y + h) > svg_h:
            out_of_bounds.append((x, y, w, h))
            
    print(f"X-range: {min_x} to {max_x}")
    print(f"Viewport Width: {svg_w}")

    if out_of_bounds:
        print(f"Found {len(out_of_bounds)} nodes out of bounds:")
        for r in out_of_bounds[:10]:
            print(f"  Rect: x={r[0]}, y={r[1]}, w={r[2]}, h={r[3]}")
    else:
        print("All nodes within bounds.")

if __name__ == '__main__':
    check_bounds(sys.argv[1])
