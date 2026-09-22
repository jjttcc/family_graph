#!/usr/bin/env ruby

root = 'FG_ROOT'
root_path = ENV[root]
setup_path = "#{root_path}/setup.rb"
if ! ENV[root] then
  $stderr.puts "environment variable #{root} must be set."
  exit 2
end
require setup_path
require 'data_loader'
require 'family_constants'
require 'coordinates'
require 'graph_renderer'
require 'hierarchy_analyzer'
require 'layout_pipeline'
require 'hierarchical_placement_step'
require 'layout_context'

def assert(condition, message)
  if !condition then
    puts "Assertion Failed: #{message}"
    exit 1
  end
end

# 1. Coordinates Class Verification
puts "Verifying Coordinates class..."
coords = Coordinates.new

# Add nodes
coords.add_node(PersonNode.new(Person.new('person_1', {}), 100, 200))
coords.add_node(PersonNode.new(Person.new('person_2', {}), 150, 200))

assert(coords.has_node?('person_1'),
       "person_1 should exist in coordinates")
assert(coords.node_by_person_id('person_1').x == 100 && 
       coords.node_by_person_id('person_1').y == 200,
       "person_1 coordinates mismatched")
assert(!coords.has_node?('person_3'),
       "person_3 should not exist in coordinates")

# Add spouses and check uniqueness/sorting
p1 = coords.node_by_person_id('person_1')
p2 = coords.node_by_person_id('person_2')
couple = CoupleNode.new(p1, p2, 125, 200)
coords.add_couple(couple)
# Try adding same couple again (should not duplicate)
coords.add_couple(couple)

assert(coords.couples.size == 1,
       "Should only have 1 spousal couple registered")
couple_id = coords.couples.keys.first
assert(couple_id == 'person_1.person_2',
       "Spouse pairing sorting failed: #{couple_id}")

puts "Coordinates class verification PASSED!"

# 2. Loader Verification
data_path = File.join(__dir__, '..', 'data', 'sample_tree.yaml')
people = DataLoader.load(data_path)
puts "Successfully loaded #{people.size} people."

test_cases = {
  'root_ancestor_100' => 2,
  'bob_doe_101' => 1,
  'child_gen1_200' => 3,
  'grandchild_gen2_300' => 1,
  'frank_smith_301' => 1,
  'grandchild_gen2_302' => 0,
  'great_grandchild_gen3_400' => 0,
  'multi_spouse_400' => 0,
  'baptism_test_person_500' => 0
}

puts "Running extensive structural assertions..."

test_cases.each do |id, expected_children|
  person = people[id]
  assert(person != nil, "Person #{id} should exist")
  assert(person.children.size == expected_children,
         "#{id} should have #{expected_children} children, but has " \
         "#{person.children.size}")
end

puts "All #{test_cases.size} structural assertions PASSED!"

# 3. Layout Engine Verification
puts "Verifying Layout Engine (Modern Pipeline)..."
root_person = people.values.find { |p| p.father.nil? && p.mother.nil? }
assert(root_person != nil, "A root person must exist in the sample data")

HierarchyAnalyzer.new.calculate_and_assign_generations(people)
context = LayoutContext.new(people,
                            [root_person],
                            Coordinates.new,
                            :descendant)
pipeline = LayoutPipeline.new([HierarchicalPlacementStep.new])
pipeline.execute(context)
layout_coords = context.coordinates

root_node = layout_coords.node_for_person(root_person)
assert(root_node != nil, "Root #{root_person.id} should have coordinates. " +
       "Nodes: #{layout_coords.single_nodes.keys}")

assert(root_node.y == 0, "Root should be at level 0")

if root_person.has_spouse then
  root_person.spouses.each do |spouse|
    spouse_node = layout_coords.node_for_person(spouse)
    assert(spouse_node != nil, "Root spouse should have coordinates")
    assert(spouse_node.y == 0, "Spouse should be at level 0")
    puts "DEBUG: Root X: #{root_node.x}, Spouse X: #{spouse_node.x}"
    expected_spacing = NODE_WIDTH + 20
    assert((spouse_node.x - root_node.x).abs == expected_spacing,
           "Spouses should be separated. Expected: #{expected_spacing}, " \
           "Got: #{(spouse_node.x - root_node.x).abs}")
  end
end

# Verify children are positioned centered beneath the couple
if !root_person.children.empty? then
  children = root_person.children
  child_xs = children.map { |c| layout_coords.node_for_person(c).x }
  midpoint = (child_xs.min + child_xs.max) / 2
  if root_person.has_spouse then
    spouse_id = root_person.spouses.first.id
    spouse_node = layout_coords.node_for_person(root_person.spouses.first)
    spouse_x = spouse_node.x
    couple_midpoint = (root_node.x + spouse_x) / 2
    puts "DEBUG: midpoint: #{midpoint}, couple_midpoint: #{couple_midpoint}"
    if (midpoint - couple_midpoint).abs >= 1 then
      assert(false, "Children should be centered beneath root couple midpoint: " +
             "midpoint: #{midpoint}, couple_midpoint: #{couple_midpoint}")
    end
  else
    if (midpoint - root_x).abs >= 1 then
      assert(false, "Children should be centered beneath root")
    end
  end
end

puts "\nLayout Engine verification PASSED!"

# 4. Rendering Verification
puts "Verifying SVG Renderer..."
output_dir = File.join(__dir__, '..', 'output')
Dir.mkdir(output_dir) unless Dir.exist?(output_dir)
renderer = GraphRenderer.new(layout_coords, people)
renderer.render(output_dir, 'suite_test')

svg_files = Dir.glob(File.join(output_dir, "family_tree_suite_test_*.svg"))
assert(!svg_files.empty?,
       "SVG output file was not created in #{output_dir}")

latest_svg = svg_files.max_by { |f| File.mtime(f) }
svg_content = File.read(latest_svg)
assert(svg_content.include?("David Doe +"),
       "Multi-spouse person 'David Doe' should have '+' indicator")
assert(svg_content.include?("1950-01-01 [bap]"),
       "Baptism person 'Baptism Test' should have '[bap]' indicator")

puts "SVG Renderer verification PASSED!"
