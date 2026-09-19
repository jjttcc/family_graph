#!/usr/bin/env ruby
# Comprehensive CLI regression test suite for main.rb

root = 'FG_ROOT'
root_path = ENV[root]
setup_path = "#{root_path}/setup.rb"
if ! ENV[root] then
  $stderr.puts "environment variable #{root} must be set."
  exit 2
end
require setup_path
require 'fileutils'
require 'tmpdir'

def assert(condition, message)
  if !condition then
    puts "Assertion Failed: #{message}"
    exit 1
  end
end

# Ensure we are running from the project root
Dir.chdir(File.join(__dir__, '..'))

def run_cli(args)
  reader, writer = IO.pipe
  pid = fork do
    reader.close
    $stdout.reopen(writer)
    $stderr.reopen(writer)
    # Split args safely
    exec("ruby", "src/main/main.rb", *args.split)
  end
  writer.close
  output = reader.read
  _, status = Process.wait2(pid)
  return output, status.exitstatus
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
#require_relative '../src/family_constants'
require 'family_constants'
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
  out, status = run_cli("-i child_gen1_200 data/sample_tree.yaml -o #{tmpdir} -s 1")
  if status != 0 then
    puts "CLI Output: #{out}"
  end
  assert(status == 0, "Root ID flag should exit with 0")
  glob_pattern = File.join(tmpdir, "family_tree_child_gen1_200_*.svg")
  assert(Dir.glob(glob_pattern).any?, "SVG should be generated")
end

# Test -i / --root (Multiple roots, unified rendering)
Dir.mktmpdir do |tmpdir|
  out, status = run_cli("-i child_gen1_200,baptism_test_person_500 " \
                        "data/sample_tree.yaml -o #{tmpdir} -s 1")
  assert(status == 0, "Multiple Root IDs flag should exit with 0")
  glob_pattern = File.join(tmpdir, "family_tree_unified_*.svg")
  assert(Dir.glob(glob_pattern).any?, "Unified SVG should be generated")
end

# Test -i / --root (All roots) - Now implicitly handled
Dir.mktmpdir do |tmpdir|
  out, status = run_cli("data/sample_tree.yaml -o #{tmpdir} -s 1")
  assert(status == 0, "Default root (all) should exit with 0")
  glob_pattern = File.join(tmpdir, "family_tree_unified_*.svg")
  assert(Dir.glob(glob_pattern).any?, "Unified SVG should be generated")
end

# Test -d / --direction
Dir.mktmpdir do |tmpdir|
  out, status = run_cli("data/sample_tree.yaml -o #{tmpdir} -d descent -s 1")
  if status != 0 then
    puts "CLI Output: #{out}"
  end
  assert(status == 0, "Direction flag should exit with 0")
end

# Test -t / --traversal
Dir.mktmpdir do |tmpdir|
  out, status = run_cli("data/sample_tree.yaml -o #{tmpdir} -t ancestor -s 1")
  assert(status == 0, "Traversal flag should exit with 0")
end

# Test -m / --label-mode
Dir.mktmpdir do |tmpdir|
  out, status = run_cli("data/sample_tree.yaml -o #{tmpdir} -m ids -s 1")
  assert(status == 0, "Label-mode flag should exit with 0")
end

puts "All CLI Regression Tests PASSED!"
