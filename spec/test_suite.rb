#!/bin/env ruby

require_relative '../src/data_loader'
require_relative '../src/family_constants'
require_relative '../src/coordinates'
require_relative '../src/graph'

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
assert(coords.get_node('person_1') == [100, 200], "person_1 coordinates mismatched")
assert(!coords.has_node?('person_3'), "person_3 should not exist in coordinates")

# Add spouses and check uniqueness/sorting
coords.add_couple('person_1', 'person_2')
coords.add_couple('person_2', 'person_1') # Duplicate with reversed order

assert(coords.couples.size == 1, "Should only have 1 spousal couple registered")
assert(coords.couples.first == ['person_1', 'person_2'].sort, "Spouse pairing sorting failed")

puts "Coordinates class verification passed!"

# 2. Loader Verification
data_path = '/home3/development/jtc/relatives/gemini/output-formatting/manual_engine/data/master_tree.yaml'
people = DataLoader.load(data_path)
puts "Successfully loaded #{people.size} people."

# Define test cases: { id => expected_children_count }
# Checking a mix of roots, intermediate nodes, and leaves
test_cases = {
  'john_frost_1680' => 3,     # Root
  'william_frost_1713' => 6,  # Intermediate
  'james_frost_1751' => 1,    # Intermediate
  'walter_westcott_1742' => 1,# Intermediate
  'elizabeth_westcott_1834' => 0, # Leaf
  'ann_frost_1741' => 0,      # Leaf
  'robert_frost_1710' => 0,   # Leaf
  'john_westcott_1756' => 2   # Intermediate
}

puts "Running extensive structural assertions..."

test_cases.each do |id, expected_children|
  person = people[id]
  assert(person != nil, "Person #{id} should exist")
  assert(person.children.size == expected_children, 
         "#{id} should have #{expected_children} children, but has #{person.children.size}")
  
  # Verify bidirectional linking (child's parent should be this person)
  person.children.each do |child|
    parent_id = child.data[FATHER] || child.data[MOTHER]
    assert(parent_id == id, 
           "Child #{child.id} of #{id} should have #{id} as parent, but has #{parent_id}")
  end
end

puts "All #{test_cases.size} structural assertions passed!"

# 3. Layout Engine Verification
puts "Verifying Layout Engine (Graph)..."
root_person = people['john_frost_1680']
graph = Graph.new(root_person)
layout_coords = graph.coordinates

# Verify coordinates generated for root and spouse
assert(layout_coords.has_node?('john_frost_1680'), "Root should have coordinates")
assert(layout_coords.has_node?('ruth_baker_1684'), "Root spouse should have coordinates")

john_x, john_y = layout_coords.get_node('john_frost_1680')
ruth_x, ruth_y = layout_coords.get_node('ruth_baker_1684')

assert(john_y == 0, "Root should be at level 0")
assert(ruth_y == 0, "Spouse should be at level 0")
assert((ruth_x - john_x).abs == Graph::COUPLE_SPACING, "Spouses should be separated by couple spacing")

# Verify children are positioned centered beneath the couple
children = root_person.children
assert(children.size == 3, "Root should have 3 children in layout")

child_xs = children.map { |c| layout_coords.get_node(c.id)[0] }
midpoint = (child_xs.min + child_xs.max) / 2
couple_midpoint = (john_x + ruth_x) / 2

assert(midpoint == couple_midpoint, "Children should be centered beneath root couple midpoint")

# Print coordinates for visual baseline check
puts "\nGenerated Coordinates Baseline:"
layout_coords.nodes.sort_by { |k, v| [v[1], v[0]] }.each do |id, (x, y)|
  puts "  #{id.ljust(25)}: (#{x.to_s.rjust(4)}, #{y.to_s.rjust(3)})"
end

puts "\nLayout Engine verification passed!"
