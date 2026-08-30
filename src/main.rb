#!/usr/bin/env ruby

require 'optparse'

require_relative 'descendant_graph'
require_relative 'ancestor_graph'
require_relative 'data_loader'
require_relative 'graph_renderer'
require_relative 'family_constants'

options = {
  root_ids: nil,
  direction: :none,
  traversal: :descendant,
  output_dir: Dir.pwd,
  label_mode: :dates
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: family_graph <data-path1> ... [options]"
  opts.on("-i", "--root ID1,ID2", Array,
          "Comma-separated list of root person IDs") do |v|
    options[:root_ids] = v
  end
  opts.on("-d", "--direction DIR", [:ancestry, :descent, :none],
          "Direction (ancestry/a, descent/d, none/n)") do |v|
    options[:direction] = v
  end
  opts.on("-t", "--traversal TYPE", [:ancestor, :descendant],
          "Traversal type (ancestor/descendant)") do |v|
    options[:traversal] = v
  end
  opts.on("-m", "--label-mode MODE", [:dates, :ids, :both],
          "Label mode (dates, ids, both)") do |v|
    options[:label_mode] = v
  end
  opts.on("-o", "--output DIR", "Output directory (default: .)") do |v|
    options[:output_dir] = v
  end
  opts.on("-l", "--list-all", "List all person IDs") do
    options[:list_all] = true end
  opts.on("-r", "--list-roots", "List all root person IDs") do
    options[:list_roots] = true
  end
  opts.on("-h", "--help", "Show this help message") do
    puts opts
    exit
  end
  opts.on("-v", "--version", "Show application version") do
    puts VERSION
    exit
  end
end

parser.parse!

# Determine if we are just listing IDs
if options[:list_all] || options[:list_roots]
  if ARGV.empty?
    puts "Error: Data file path is required for listing."
    exit 1
  end
  people = {}
  ARGV.each do |path|
    people.merge!(DataLoader.load(path)) if File.exist?(path)
  end
  if options[:list_all]
    puts people.keys.sort
  elsif options[:list_roots]
#!!!_id not needed
    roots = people.select do |_id, p|
      p.father.nil? && p.mother.nil?
    end
    puts roots.keys.sort
  end
  exit
end

# Otherwise, positional data paths are mandatory
if ARGV.empty?
  puts "Error: Data file path is required."
  exit 1
end

people = {}
ARGV.each do |path|
  unless File.exist?(path)
    puts "Error: Data file '#{path}' not found."
    next
  end
  puts "Loading data from #{path}..."
  people.merge!(DataLoader.load(path))
end

# Use provided root IDs, or default to all roots
all_roots = people.select do |_id, p|
  p.father.nil? && p.mother.nil?
end
root_ids = options[:root_ids] || all_roots.keys

root_ids.each do |root_id|
  unless people.key?(root_id)
    puts "Error: Root person '#{root_id}' not found."
    next
  end
  puts "Generating graph for #{root_id}..."
  graph_class = options[:traversal] == :ancestor ? AncestorGraph : DescendantGraph
  graph = graph_class.new(people[root_id])
  puts "Rendering SVG..."
  renderer = GraphRenderer.new(graph.coordinates, people,
                               options[:direction],
                               options[:label_mode])
  renderer.render(options[:output_dir], root_id)
end
