#!/usr/bin/env python3
import sys
import xml.etree.ElementTree as ET

def analyze_svg(filepath):
    print(f"=== Analyzing {filepath} ===")
    try:
        tree = ET.parse(filepath)
        root = tree.getroot()
    except Exception as e:
        print(f"Error parsing {filepath}: {e}")
        return

    ns = {'svg': 'http://www.w3.org/2000/svg'}
    
    # Find all <g> groups or rects
    # Let's inspect rects and texts
    rects = root.findall('.//svg:rect', ns)
    if not rects:
        rects = root.findall('.//rect')

    nodes = []
    for rect in rects:
        x = rect.attrib.get('x')
        y = rect.attrib.get('y')
        width = rect.attrib.get('width')
        height = rect.attrib.get('height')
        try:
            w_val = float(width) if width else 0.0
            h_val = float(height) if height else 0.0
            x_val = float(x) if x else 0.0
            y_val = float(y) if y else 0.0
        except ValueError:
            continue
        
        if w_val > 50 and h_val > 30 and '100%' not in str(width):
            nodes.append({
                'x': x_val,
                'y': y_val,
                'width': w_val,
                'height': h_val
            })

    nodes.sort(key=lambda n: (n['y'], n['x']))
    print(f"Total person/couple nodes found: {len(nodes)}")
    for i, n in enumerate(nodes):
        print(f"  Node {i+1:2d}: x={n['x']:6.1f}, y={n['y']:5.1f}, w={n['width']:5.1f}, h={n['height']:4.1f}")
    print()

if __name__ == '__main__':
    paths = [
        "work/family_tree_unified_20261018_140858_pseudo-oracle.svg",
        "work/family_tree_unified_20261018_192547_pseudo-oracle.svg",
        "work/family_tree_unified_20261019_103813_oracle-candidate.svg"
    ]
    for p in paths:
        analyze_svg(p)
