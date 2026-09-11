import subprocess
import os

def run_tests():
    # Update constants and run generator
    # For now, manually adjust in constants file using python
    # Then run generation
    subprocess.run(["ruby", "src/main.rb", "-i", "{all}", "../../work/data/refined_tree_data/master_tree.yaml", "-o", "output"], check=True)
    
    # Extract rects
    latest_svg = sorted([f for f in os.listdir('output') if f.endswith('.svg')])[-1]
    subprocess.run(f"grep '<rect' output/{latest_svg} > rects.txt", shell=True)
    
    # Check for overlaps
    overlap_res = subprocess.run(["python3", "check_overlaps.py"], capture_output=True, text=True)
    
    # Check gaps
    gap_res = subprocess.run(["python3", "analyze_gaps.py"], capture_output=True, text=True)
    
    return overlap_res.stdout.strip(), gap_res.stdout.strip()

# Iterative Tuning
# Original: LEVEL_HEIGHT=200, COUPLE_SPACING=140, SIBLING_SPACING=150
# Let's try: LEVEL_HEIGHT=200, COUPLE_SPACING=100, SIBLING_SPACING=120
print("Tuning constants...")
# [Manual edit of src/family_constants.rb via subprocess or just python is safer]
# I will do this in the next steps.
