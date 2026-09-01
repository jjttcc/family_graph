#!/usr/bin/env ruby

require_relative '../src/data_loader'
require_relative '../src/descendant_graph'
require_relative '../src/graph_renderer'
require_relative '../src/family_constants'
require_relative '../src/descendant_graph'

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

# Test :descent with DescendantGraph
puts "Rendering Descent graph..."
des_graph = DescendantGraph.new(alice)
renderer = GraphRenderer.new(des_graph.coordinates, people, :descent, :ids)
renderer.render(output_dir, 'descent_test')

# Test :none with DescendantGraph
puts "Rendering None graph..."
renderer = GraphRenderer.new(des_graph.coordinates, people, :none, :dates)
renderer.render(output_dir, 'none_test')

puts "Renderer options passed!"
puts "All regression tests passed!"
