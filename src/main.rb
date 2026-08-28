#!/usr/bin/env ruby

require 'optparse'
require_relative 'data_loader'
require_relative 'graph'
require_relative 'graph_renderer'
require_relative 'family_constants'

options = {
  root_ids: nil,
  direction: :ancestry,
  output_dir: Dir.pwd
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: main.rb [options]"

  opts.on("-i", "--root ID1,ID2", Array,
          "Comma-separated list of root person IDs") do |v|
    options[:root_ids] = v
  end

  opts.on("-d", "--direction DIR", [:ancestry, :descent, :none],
          "Direction (ancestry/a, descent/d, none/n)") do |v|
    options[:direction] = v
  end

  opts.on("-o", "--output DIR", "Output directory (default: .)") do |v|
    options[:output_dir] = v
  end

  opts.on("-l", "--list-all", "List all person IDs") { options[:list_all] = true }

  opts.on("-r", "--list-roots", "List all root person IDs") do
    options[:list_roots] = true
  end

  opts.on("-h", "--help", "Show this help message") do
    puts opts
    exit
  end
end

if ARGV.empty?
  puts parser
  exit
end

parser.parse!

data_path = File.expand_path('../../../manual_engine/data/master_tree.yaml',
                             __FILE__)

puts "Loading data from #{data_path}..."
people = DataLoader.load(data_path)

if options[:list_all]
  puts people.keys.sort
  exit
end

# Helper to find all roots (those with no parent fields)
all_roots = people.select do |_id, p|
  !p.respond_to?(:father) && !p.respond_to?(:mother)
end

if options[:list_roots]
  puts all_roots.keys.sort
  exit
end

# Use provided root IDs, or default to all roots
root_ids = options[:root_ids] || all_roots.keys

root_ids.each do |root_id|
  unless people.key?(root_id)
    puts "Error: Root person '#{root_id}' not found."
    next
  end

  puts "Generating graph for #{root_id}..."
  graph = Graph.new(people[root_id])

  puts "Rendering SVG..."
  renderer = GraphRenderer.new(graph.coordinates, people,
                               options[:direction])
  
  renderer.render(options[:output_dir], root_id)
end
