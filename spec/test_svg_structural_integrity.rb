#!/usr/bin/env ruby

require 'fileutils'

def assert(condition, message)
  if not condition then
    puts "Assertion Failed: #{message}"
    exit 1
  end
end

data_path = ARGV[0] || 'data/sample_tree.yaml'
output_dir = '/tmp/test_integrity'
FileUtils.mkdir_p(output_dir)

# Render the SVG
system("./bin/family_graph -m ids #{data_path} -o #{output_dir} -d descent")

# Find the most recently generated file
svg_files = Dir.glob(File.join(output_dir, '*.svg'))
svg_file = svg_files.max_by { |f| File.mtime(f) }

svg_content = File.read(svg_file)

# Count parent-child lines (those without stroke-dasharray)
parent_child_lines = svg_content.scan(/<line[^>]*stroke="black"[^>]*>/).reject { |l| l.include?('stroke-dasharray') }.size

# Count spousal lines (those with stroke-dasharray="4")
spousal_lines = svg_content.scan(/stroke-dasharray="4"/).size

puts "Parent-Child lines: #{parent_child_lines}"
puts "Spousal lines: #{spousal_lines}"

assert(
  parent_child_lines >= 5,
  "Expected at least 5 parent-child lines, found #{parent_child_lines}"
)

assert(
  spousal_lines >= 2,
  "Expected at least 2 spousal lines, found #{spousal_lines}"
)

puts "Structural integrity test PASSED!"
