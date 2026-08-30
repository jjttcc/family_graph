#!/usr/bin/env ruby
# Comprehensive CLI regression test suite for main.rb

require 'fileutils'
require 'tmpdir'

def assert(condition, message)
  unless condition
    puts "Assertion Failed: #{message}"
    exit 1
  end
end

# Ensure we are running from the project root
Dir.chdir(File.join(__dir__, '..'))

def run_cli(args)
  cmd = "ruby src/main.rb #{args}"
  output = `#{cmd} 2>&1`
  exit_status = $?.exitstatus
  return output, exit_status
end

puts "Starting CLI Regression Tests..."

# Test -h / --help
out, status = run_cli("-h")
assert(status == 0, "Help should exit with 0")
assert(out.include?("Usage:"), "Help should display usage")

# Test -v / --version
out, status = run_cli("-v")
assert(status == 0, "Version should exit with 0")
# Version is defined in family_constants.rb
require_relative '../src/family_constants'
assert(out.include?(VERSION), "Version should display #{VERSION}")

# Test -l / --list-all
out, status = run_cli("-l data/sample_tree.yaml")
assert(status == 0, "List-all should exit with 0")
assert(out.include?("root_ancestor_100"), "List-all should contain root ID")

# Test -r / --list-roots
out, status = run_cli("-r data/sample_tree.yaml")
assert(status == 0, "List-roots should exit with 0")
assert(out.include?("root_ancestor_100"), "List-roots should contain root ID")

# Test -i / --root (Custom root)
Dir.mktmpdir do |tmpdir|
  out, status = run_cli("-i child_gen1_200 data/sample_tree.yaml -o #{tmpdir}")
  assert(status == 0, "Root ID flag should exit with 0")
  assert(Dir.glob(File.join(tmpdir, "family_tree_child_gen1_200_*.svg")).any?, "SVG should be generated")
end

# Test -d / --direction
Dir.mktmpdir do |tmpdir|
  out, status = run_cli("data/sample_tree.yaml -o #{tmpdir} -d descent")
  assert(status == 0, "Direction flag should exit with 0")
end

# Test -t / --traversal
Dir.mktmpdir do |tmpdir|
  out, status = run_cli("data/sample_tree.yaml -o #{tmpdir} -t ancestor")
  assert(status == 0, "Traversal flag should exit with 0")
end

# Test -m / --label-mode
Dir.mktmpdir do |tmpdir|
  out, status = run_cli("data/sample_tree.yaml -o #{tmpdir} -m ids")
  assert(status == 0, "Label-mode flag should exit with 0")
end

puts "All CLI Regression Tests passed!"
