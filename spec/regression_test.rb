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
HierarchyAnalyzerStep.new.execute(context)
pipeline = LayoutPipeline.new([HierarchicalPlacementStep.new])
pipeline.execute(context)
renderer = GraphRenderer.new(context.coordinates, :descent, :ids)
renderer.render(output_dir, 'descent_test')
# Test :none with HierarchicalPlacement
puts "Rendering None graph..."
renderer = GraphRenderer.new(context.coordinates, :none, :dates)
renderer.render(output_dir, 'none_test')

puts "Renderer options passed!"
puts "All regression tests PASSED!"
