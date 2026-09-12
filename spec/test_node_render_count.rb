#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'
require_relative '../src/data_loader'
require_relative '../src/descendant_graph'
require_relative '../src/graph_renderer'
require_relative '../src/initial_placement_strategy'
require_relative '../src/layout_pipeline'
require_relative '../src/hierarchy_analyzer'

def assert(condition, message)
  unless condition
    puts "Assertion Failed: #{message}"
    exit 1
  end
end

data_path = ARGV[0] || 'data/sample_tree.yaml'
output_dir = '/tmp/test_output'
FileUtils.mkdir_p(output_dir)

puts "Testing node count for: #{data_path}"
people = DataLoader.load(data_path)
expected_node_count = people.size

HierarchyAnalyzer.calculate_generations(people)
roots = people.select { |_id, p| p.father.nil? && p.mother.nil? }.values
graph = DescendantGraph.new(LayoutPipeline.new([InitialPlacementStrategy.new]))
graph.instance_variable_set(:@roots, roots)
graph.build(roots)

renderer = GraphRenderer.new(graph.coordinates, people, :descent, :ids)
renderer.render(output_dir, 'node_count_test')

# Find the most recently generated file
svg_files = Dir.glob(File.join(output_dir, 'family_tree_node_count_test_*.svg'))
svg_file = svg_files.max_by { |f| File.mtime(f) }

svg_content = File.read(svg_file)
# Count only rects with x/y/width/height attributes, which are nodes,
# ignoring the background rect that just has width/height="100%".
actual_rect_count = svg_content.scan(/<rect\s+x=/).size

puts "Expected nodes: #{expected_node_count}"
puts "Actual <rect> count: #{actual_rect_count}"

assert(
  actual_rect_count == expected_node_count,
  "Node count mismatch! Expected #{expected_node_count}, " +
  "found #{actual_rect_count}"
)

puts "Node count test PASSED!"
