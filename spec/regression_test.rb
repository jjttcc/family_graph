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
require 'graph_renderer'
require 'family_constants'
require 'layout_pipeline'
require 'coordinates'
require 'layout_context'
require 'hierarchical_placement_step'
require 'hierarchy_analyzer_step'
require 'node_creator_step'
require 'width_calculator_step'

def assert(condition, message)
  unless condition
    puts "Assertion Failed: #{message}"
    exit 1
  end
end

data_path = 'data/sample_tree.yaml'

people = DataLoader.load(data_path)

# 1. Spouse Linking Verification
puts "Verifying Spouse Bi-directional linking..."
# Alice lists Bob, ensure Bob lists Alice automatically
alice = people['root_ancestor_100']
bob = people['bob_doe_101']

assert(alice.spouses.include?(bob), "Alice should list Bob")
assert(bob.spouses.include?(alice), "Bob should list Alice")
assert(alice.spouses.size == 1, "Should have only one spouse")
puts "Spouse linking passed!"

# 2. Renderer Options Verification
puts "Verifying Renderer Options..."
output_dir = 'output'

# Test :descent with HierarchicalPlacement
puts "Rendering Descent graph..."
context = LayoutContext.new(people, people.values.select { |p| p.is_root },
                            Coordinates.new, :descendant)
pipeline = LayoutPipeline.new([
  HierarchyAnalyzerStep.new(context),
  NodeCreatorStep.new(context),
  WidthCalculatorStep.new(context),
  HierarchicalPlacementStep.new(context)
])
pipeline.execute(context)
renderer = GraphRenderer.new(context.coordinates, :descent, :ids)
renderer.render(output_dir, 'descent_test')
# Test :none with HierarchicalPlacement
puts "Rendering None graph..."
renderer = GraphRenderer.new(context.coordinates, :none, :dates)
renderer.render(output_dir, 'none_test')

puts "Renderer options passed!"

# 3. Parent-Child Line Geometry & Arrowhead Verification
puts "Verifying Parent-Child line geometry and arrowheads..."
svg_files = Dir.glob(File.join(output_dir,
                               "family_tree_descent_test_*.svg"))
assert(!svg_files.empty?, "Descent SVG output file should exist")
descent_svg = svg_files.max_by { |f| File.mtime(f) }
svg_content = File.read(descent_svg)

parent_child_line_found = false
context.coordinates.all_person_nodes.each do |node|
  if node.is_a?(PersonNode) && node.is_primary_representation then
    person = node.person
    person.parents.each do |parent|
      parent_node = context.coordinates.node_for_person(parent)
      if parent_node then
        all_nodes = context.coordinates.single_nodes.values +
                    context.coordinates.couples.values.flat_map { |c|
                      [c.partner_a, c.partner_b]
                    }
        min_x = all_nodes.map { |n| n.x }.min
        min_y = all_nodes.map { |n| n.y }.min
        offset_x = -min_x + RENDER_OFFSET_X
        offset_y = -min_y + RENDER_OFFSET_Y

        x1 = node.x + (NODE_WIDTH / 2) + offset_x
        y1 = node.y + offset_y
        x2 = parent_node.x + (NODE_WIDTH / 2) + offset_x
        y2 = parent_node.y + NODE_HEIGHT + offset_y

        expected_pattern = "x1=\"#{x1}\" y1=\"#{y1}\" " \
                           "x2=\"#{x2}\" y2=\"#{y2}\""
        if svg_content.include?(expected_pattern) &&
           svg_content.include?("marker-end=\"url(#arrowhead)\"") then
          parent_child_line_found = true
        end
      end
    end
  end
end

assert(parent_child_line_found,
       "Generated SVG must contain correctly anchored lines with arrowheads")
puts "Parent-Child line geometry and arrowhead verification PASSED!"

puts "All regression tests PASSED!"
