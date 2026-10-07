#!/usr/bin/env ruby

root = 'FG_ROOT'
root_path = ENV[root]
setup_path = "#{root_path}/setup.rb"
if ! ENV[root] then
  $stderr.puts "environment variable #{root} must be set."
  exit 2
end
require setup_path
require 'rexml/document'
require 'data_loader'
require 'layout_orchestrator'
require 'graph_renderer'

puts "Verifying SVG validity and absence of duplicate attributes..."

data_files = [
  "#{root_path}/data/sample_tree_extended.yaml",
  "#{root_path}/data/sample_tree.yaml",
  "#{root_path}/data/normal_ancestor_tree.yaml"
]

tmp_dir = "#{root_path}/tmp"
Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)

data_files.each do |data_file|
  next unless File.exist?(data_file)
  puts "Testing SVG generation for #{File.basename(data_file)}..."
  data = DataLoader.new(data_file).load
  orchestrator = LayoutOrchestrator.new(data)
  coordinates = orchestrator.run

  renderer = GraphRenderer.new(coordinates, ANCESTRY)
  renderer.render(tmp_dir, "validity_test_#{File.basename(data_file, '.yaml')}")

  svg_files = Dir["#{tmp_dir}/family_tree_validity_test_*.svg"]
  svg_file = svg_files.max_by { |f| File.mtime(f) }
  svg_content = File.read(svg_file)

  # 1. Parse XML well-formedness
  begin
    REXML::Document.new(svg_content)
  rescue => e
    $stderr.puts "XML well-formedness FAILED for #{data_file}: #{e.message}"
    exit 1
  end

  # 2. Check for duplicate attributes within any single XML tag
  # Match each tag <... \n ...> and check attribute names
  tag_pattern = /<([a-zA-Z0-9_-]+)([^>]+)>/m
  svg_content.scan(tag_pattern) do |tag_name, attrs_str|
    attr_names = []
    # Match attribute name="value" or attribute=value
    attr_pattern = /\b([a-zA-Z0-9_-]+)\s*=/
    attrs_str.scan(attr_pattern) do |attr_name,|
      if attr_names.include?(attr_name) then
        $stderr.puts "SVG validation FAILED: Attribute '#{attr_name}' redefined in <#{tag_name}> tag!"
        exit 1
      end
      attr_names << attr_name
    end
  end
end

puts "SVG validity verification PASSED!"
exit 0
