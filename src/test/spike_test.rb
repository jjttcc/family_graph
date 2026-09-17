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
require 'graph_builder'

data_dir = "#{root_path}/../data"
data_path = File.join(data_dir, 'sample_tree.yaml')
people = DataLoader.load(data_path)
nodes, edges = GraphBuilder.build(people)
puts "Spike successful: Built #{nodes.size} nodes and #{edges.size} edges."
