#!/usr/bin/env ruby

root = 'FG_ROOT'
root_path = ENV[root]
setup_path = "#{root_path}/setup.rb"
if ! ENV[root] then
  $stderr.puts "environment variable #{root} must be set."
  exit 2
end
require setup_path
require 'coordinates'
require 'line_crossing_analysis'
require 'line_crossing_resolution'
require 'node_swap_resolution'
require 'sibling_reorder_resolution'
require 'person'
require 'graph_primitives'
require 'data_loader'

def assert(condition, message)
  if !condition then
    puts "Assertion Failed: #{message}"
    exit 1
  end
end

puts "Running LineCrossingAnalysis & Resolution verification tests..."

# Test: Explicit crossing setup
p1 = Person.new('p1', {})
p2 = Person.new('p2', {})
c1 = Person.new('c1', {})
c2 = Person.new('c2', {})

c1.father = p1
p1.add_child(c1)

c2.father = p2
p2.add_child(c2)

n_p1 = PersonNode.new(p1, 0, 0)
n_p2 = PersonNode.new(p2, 200, 0)
n_cx1 = PersonNode.new(c1, 200, 100) # c1 under p2 (crossing line)
n_cx2 = PersonNode.new(c2, 0, 100)   # c2 under p1 (crossing line)

coords = Coordinates.new
coords.add_single_node(n_p1)
coords.add_single_node(n_p2)
coords.add_single_node(n_cx1)
coords.add_single_node(n_cx2)

analyzer = LineCrossingAnalysis.new(coords)
crossings = analyzer.crossing_pairs
assert(crossings.size == 1, "Expected 1 crossing pair, got #{crossings.size}")
puts "Test (Explicit Crossing Detection): PASSED"

# Test: NodeSwapResolution execution on crossings
resolver = NodeSwapResolution.new(coords)
resolver.execute(crossings)
# After resolver execution (swapping x coordinates of cx1 and cx2)
assert(n_cx1.x == 0 && n_cx2.x == 200, "Resolver should swap X coordinates of crossing nodes")
puts "Test (Explicit Crossing Resolution): PASSED"

# Test: Parallel non-crossing setup
coords2 = Coordinates.new
coords2.add_single_node(PersonNode.new(p1, 0, 0))
coords2.add_single_node(PersonNode.new(p2, 200, 0))
coords2.add_single_node(PersonNode.new(c1, 0, 100))   # c1 under p1 (parallel)
coords2.add_single_node(PersonNode.new(c2, 200, 100)) # c2 under p2 (parallel)

analyzer2 = LineCrossingAnalysis.new(coords2)
crossings2 = analyzer2.crossing_pairs
assert(crossings2.empty?, "Expected 0 crossing pairs, got #{crossings2.size}")
puts "Test (Parallel Non-Crossing): PASSED"

puts "All LineCrossingAnalysis & Resolution verification tests PASSED!"
exit 0
