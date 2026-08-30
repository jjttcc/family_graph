#!/usr/bin/env ruby
# Test the '-d' direction functionality with explicit file inspection

require 'fileutils'
require 'tmpdir'

def assert(condition, message)
  unless condition
    puts "Assertion Failed: #{message}"
    exit 1
  end
end

Dir.mktmpdir do |tmpdir|
  # 1. Test -d none (default should have NO arrowheads)
  puts "Testing -d none..."
  `ruby src/main.rb data/sample_tree.yaml -o #{tmpdir} -d none`
  svg_files = Dir.glob(File.join(tmpdir, "*.svg"))
  svg_content = File.read(svg_files.first)
  # Verify that marker-end is NOT in the parent-child lines
  assert(!svg_content.include?("marker-end=\"url(#arrowhead)\""), 
         "Direction :none should not have any arrowhead markers on lines")

  # 2. Test -d descent (should have parent-child arrows pointing down)
  puts "Testing -d descent..."
  FileUtils.rm_rf(Dir.glob(File.join(tmpdir, "*")))
  `ruby src/main.rb data/sample_tree.yaml -o #{tmpdir} -d descent`
  svg_files = Dir.glob(File.join(tmpdir, "*.svg"))
  svg_content = File.read(svg_files.first)
  assert(svg_content.include?("marker-end=\"url(#arrowhead)\""), 
         "Direction :descent should have arrowhead markers on parent-child lines")
end

puts "Direction (-d) test passed!"
