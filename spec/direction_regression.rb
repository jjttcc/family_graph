#!/usr/bin/env ruby
# Test the '-d' direction functionality

require 'fileutils'
require 'tmpdir'

def assert(condition, message)
  unless condition
    puts "Assertion Failed: #{message}"
    exit 1
  end
end

Dir.mktmpdir do |tmpdir|
  # 1. Test -d none (default)
  puts "Testing -d none..."
  `ruby src/main.rb data/sample_tree.yaml -o #{tmpdir} -d none`
  svg_files = Dir.glob(File.join(tmpdir, "*.svg"))
  svg_content = File.read(svg_files.first)
  assert(!svg_content.include?("marker-end"), "Direction :none should not have arrowheads")

  # 2. Test -d descent (arrows present)
  puts "Testing -d descent..."
  `ruby src/main.rb data/sample_tree.yaml -o #{tmpdir} -d descent`
  svg_files = Dir.glob(File.join(tmpdir, "*.svg"))
  svg_content = File.read(svg_files.first)
  assert(svg_content.include?("marker-end"), "Direction :descent should have arrowheads")
end

puts "Direction (-d) test passed!"
