# frozen_string_literal: true

root = 'FG_ROOT'
root_path = ENV[root]
if !root_path
  $stderr.puts "environment variable #{root} must be set."
  exit 2
end
require "#{root_path}/setup.rb"
require 'yaml'
require 'date'
require 'graph_primitives'
require 'person'
require 'biological_parent'
require 'non_biological_parent'

oracle_file = ARGV[0] || 'oracle_stage_3.yaml'
unless File.exist?(oracle_file)
  $stderr.puts "Error: Oracle file #{oracle_file} not found."
  exit 1
end

data = YAML.load_file(oracle_file, permitted_classes: [Symbol, Date, PersonNode, CoupleNode, Person, BiologicalParent, NonBiologicalParent], aliases: true)
nodes = data[:nodes] || data["nodes"]
levels = Hash.new { |h, k| h[k] = [] }

nodes.each do |name, node|
  levels[node.y] << [name, node.x]
end

levels.keys.sort.each do |y|
  puts "Generation y=#{y}:"
  sorted = levels[y].sort_by { |_, x| x }
  sorted.each { |name, x| puts "  #{name}: x=#{x}" }
  gaps = sorted.each_cons(2).map { |(n1, x1), (n2, x2)| [n1, n2, x2 - x1] }
  puts "  Gaps: #{gaps}"
  puts
end
