#!/usr/bin/env ruby

root = 'FG_ROOT'
root_path = ENV[root]
setup_path = "#{root_path}/setup.rb"
if ! ENV[root] then
  $stderr.puts "environment variable #{root} must be set."
  exit 2
end
require setup_path
# Simple dependency visualizer generating a DOT file.
# Usage: ./spec/generate_dependency_graph.rb > dependencies.dot

puts "digraph G {"
puts "  node [shape=box];"

Dir.glob("src/*.rb").each do |file|
  filename = File.basename(file, '.rb')
  puts "  #{filename};"
  File.readlines(file).each do |line|
    if line =~ /require_relative\s+['"](.+)['"]/
      dependency = $1
      puts "  #{filename} -> #{dependency};"
    end
  end
end

puts "}"
