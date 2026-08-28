#!/usr/bin/env ruby

require_relative 'data_loader'
require_relative 'graph'
require_relative 'graph_renderer'
require_relative 'family_constants'

# Main driver to generate the family tree SVG
data_path = '/home3/development/jtc/relatives/gemini/output-formatting/' \
            'manual_engine/data/master_tree.yaml'

puts "Loading data from #{data_path}..."
people = DataLoader.load(data_path)

# Using john_frost_1680 as the default root
root_id = 'john_frost_1680'
root = people[root_id]
puts "Generating graph for #{root_id}..."
graph = Graph.new(root)

# Default direction is :ancestry
puts "Rendering SVG..."
renderer = GraphRenderer.new(graph.coordinates, people, :ancestry)
output_dir = '/home3/development/jtc/relatives/gemini/output-formatting/family_graph/output'
renderer.render(output_dir)

puts "Successfully rendered graph to output/"
