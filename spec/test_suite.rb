#!/bin/env ruby

require_relative '../src/data_loader'
require_relative '../src/family_constants'
require_relative '../src/coordinates'
require_relative '../src/descendant_graph'
require_relative '../src/ancestor_graph'
require_relative '../src/graph_renderer'

def assert(condition, message)
  unless condition
    puts "Assertion Failed: #{message}"
    exit 1
  end
end

# 1. Coordinates Class Verification
puts "Verifying Coordinates class..."
coords = Coordinates.new

# Add nodes
coords.add_node('person_1', 100, 200)
coords.add_node('person_2', 150, 200)

assert(coords.has_node?('person_1'), "person_1 should exist in coordinates")
assert(coords.node('person_1') == [100, 200], "person_1 coordinates mismatched")
assert(!coords.has_node?('person_3'), "person_3 should not exist in coordinates")

# Add spouses and check uniqueness/sorting
coords.add_couple('person_1', 'person_2')
coords.add_couple('person_2', 'person_1') # Duplicate with reversed order

assert(coords.couples.size == 1, "Should only have 1 spousal couple registered")
assert(coords.couples.first == ['person_1', 'person_2'].sort, "Spouse pairing sorting failed")

puts "Coordinates class verification passed!"

# 2. Loader Verification
data_path = File.join(__dir__, '..', 'data', 'sample_tree.yaml')
people = DataLoader.load(data_path)
puts "Successfully loaded #{people.size} people."

# Define test cases: { id => expected_children_count }
test_cases = {
  'root_ancestor_100' => 1,
  'bob_doe_101' => 1,
  'child_gen1_200' => 3,
  'grandchild_gen2_300' => 1,
  'frank_smith_301' => 1,
  'grandchild_gen2_302' => 0,
  'great_grandchild_gen3_400' => 0,
  'multi_spouse_400' => 0
}


puts "Running extensive structural assertions..."

test_cases.each do |id, expected_children|
  person = people[id]
  assert(person != nil, "Person #{id} should exist")
  assert(person.children.size == expected_children,
         "#{id} should have #{expected_children} children, but has " \
         "#{person.children.size}")
end

puts "All #{test_cases.size} structural assertions passed!"

# 3. Layout Engine Verification
puts "Verifying Layout Engine (Graph)..."
# Find root dynamically (no parent)
root_person = people.values.find { |p| p.father.nil? && p.mother.nil? }
assert(root_person != nil, "A root person must exist in the sample data")

puts "  Testing DescendantGraph..."
des_graph = DescendantGraph.new(root_person)
layout_coords = des_graph.coordinates

# Verify coordinates generated for root and spouse
assert(layout_coords.has_node?(root_person.id), "Root should have coordinates")
if root_person.has_spouse
  assert(layout_coords.has_node?(root_person.spouse.id), "Root spouse should have coordinates")
end

root_x, root_y = layout_coords.node(root_person.id)
assert(root_y == 0, "Root should be at level 0")

if root_person.has_spouse
  spouse_x, spouse_y = layout_coords.node(root_person.spouse.id)
  assert(spouse_y == 0, "Spouse should be at level 0")
  assert((spouse_x - root_x).abs == Graph::COUPLE_SPACING, "Spouses should be separated by couple spacing")
end

# Verify children are positioned centered beneath the couple
# (Only check if they have children)
if !root_person.children.empty?
  children = root_person.children
  child_xs = children.map { |c| layout_coords.node(c.id)[0] }
  midpoint = (child_xs.min + child_xs.max) / 2

  if root_person.has_spouse
    couple_midpoint = (root_x + layout_coords.node(root_person.spouse.id)[0]) / 2
    assert((midpoint - couple_midpoint).abs < 1, "Children should be centered beneath root couple midpoint")
  else
    assert((midpoint - root_x).abs < 1, "Children should be centered beneath root")
  end
end

puts "  Testing AncestorGraph..."
# Find a leaf dynamically (no children)
leaf_person = people.values.find { |p| p.children.empty? }
assert(leaf_person != nil, "A leaf person must exist in the sample data")
puts "  Testing AncestorGraph starting from #{leaf_person.id}..."
anc_graph = AncestorGraph.new(leaf_person)
# Basic check that AncestorGraph runs without crashing
assert(anc_graph.coordinates != nil, "AncestorGraph coordinates should be generated")
assert(anc_graph.coordinates.has_node?(leaf_person.id), "Leaf should have coordinates")
# Ensure it traversed up to root
root_id = people.values.find { |p| p.father.nil? && p.mother.nil? }.id
assert(anc_graph.coordinates.has_node?(root_id), "AncestorGraph should have traversed to root node")


# Print coordinates for visual baseline check
puts "\nGenerated Coordinates Baseline (Descendant):"
layout_coords.nodes.sort_by { |k, v| [v[1], v[0]] }.each do |id, (x, y)|
  puts "  #{id.ljust(25)}: (#{x.to_s.rjust(4)}, #{y.to_s.rjust(3)})"
end

# Print coordinates for Ancestor baseline check
puts "\nGenerated Coordinates Baseline (Ancestor):"
anc_graph.coordinates.nodes.sort_by { |k, v| [v[1], v[0]] }.each do |id, (x, y)|
  puts "  #{id.ljust(25)}: (#{x.to_s.rjust(4)}, #{y.to_s.rjust(3)})"
end

puts "\nLayout Engine verification passed!"

# 4. Rendering Verification
puts "Verifying SVG Renderer..."
output_dir = File.join(__dir__, '..', 'output')
Dir.mkdir(output_dir) unless Dir.exist?(output_dir)
renderer = GraphRenderer.new(layout_coords, people)
renderer.render(output_dir)

# Assert that at least one SVG exists in the directory
svg_files = Dir.glob(File.join(output_dir, "*.svg"))
assert(!svg_files.empty?, "SVG output file was not created in #{output_dir}")

# Verify the '+' indicator for multi_spouse_400
latest_svg = svg_files.max_by { |f| File.mtime(f) }
svg_content = File.read(latest_svg)
assert(svg_content.include?("David Doe +"), "Multi-spouse person 'David Doe' should have '+' indicator")

puts "SVG Renderer verification passed!"

