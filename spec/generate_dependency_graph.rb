#!/usr/bin/env ruby

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
