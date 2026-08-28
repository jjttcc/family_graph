#!/usr/bin/env ruby

require 'optparse'
require_relative 'data_loader'
require_relative 'graph'
require_relative 'graph_renderer'
require_relative 'family_constants'

options = {
  root: 'john_frost_1680',
  direction: :ancestry,
  output_dir: Dir.pwd
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: main.rb [options]"

  opts.on("-r", "--root ID", "Root person ID (default: john_frost_1680)") { |v| options[:root] = v }
  
  opts.on("-d", "--direction DIR", [:ancestry, :descent, :none],
          "Direction (ancestry/a, descent/d, none/n)") do |v|
    options[:direction] = v
  end

  opts.on("-o", "--output DIR", "Output directory (default: .)") do |v|
    options[:output_dir] = v
  end

  opts.on("-l", "--list-all", "List all person IDs") { options[:list_all] = true }

  opts.on("-R", "--list-roots", "List all root person IDs") do
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

if options[:list_roots]
  roots = people.select do |_id, p|
    !p.respond_to?(:father) && !p.respond_to?(:mother)
  end
  puts roots.keys.sort
  exit
end

unless people.key?(options[:root])
  puts "Error: Root person '#{options[:root]}' not found."
  exit 1
end

root = people[options[:root]]
puts "Generating graph for #{options[:root]}..."
graph = Graph.new(root)

puts "Rendering SVG..."
renderer = GraphRenderer.new(graph.coordinates, people, options[:direction])
renderer.render(options[:output_dir])

puts "Successfully rendered graph to #{options[:output_dir]}/"
