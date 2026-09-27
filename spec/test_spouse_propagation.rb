#!/usr/bin/env ruby

root = 'FG_ROOT'
root_path = ENV[root]
setup_path = "#{root_path}/setup.rb"
if ! ENV[root] then
  $stderr.puts "environment variable #{root} must be set."
  exit 2
end
require setup_path
require 'data_loader'
require 'hierarchy_analyzer_step'
require 'layout_context'
require 'coordinates'

def assert(condition, message)
  unless condition
    puts "Assertion Failed: #{message}"
    exit 1
  end
end

data_path = File.join(__dir__, '..', 'data', 'spouse_propagation_test.yaml')
people = DataLoader.load(data_path)
puts "Successfully loaded #{people.size} people."

# Calculate generations
context = LayoutContext.new(people, [], Coordinates.new, :descendant)
HierarchyAnalyzerStep.new(context).execute

# Expectations:
# wife1 (child of root) -> Gen 1
# david (child of wife1) -> Gen 2
# wife2 (child of david) -> Gen 3
# Alignment: All must be Gen 3.

puts "Verifying generations..."

assert(people['wife1'].generation == 3,
       "wife1 should be Gen 3, is #{people['wife1'].generation}")
assert(people['david'].generation == 3,
       "david should be Gen 3, is #{people['david'].generation}")
assert(people['wife2'].generation == 3,
       "wife2 should be Gen 3, is #{people['wife2'].generation}")

puts "All assertions PASSED!"
