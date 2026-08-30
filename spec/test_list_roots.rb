#!/usr/bin/env ruby
# Test the '-r' list-roots functionality

# Run main.rb -r
output = `ruby src/main.rb -r data/sample_tree.yaml`
# Roots should be nodes with no father and no mother
expected = ["bob_doe_101", "frank_smith_301", "root_ancestor_100", "spouse_1", "spouse_2"].sort
actual = output.split("\n").sort

if actual == expected
  puts "List roots (-r) test passed!"
  exit 0
else
  puts "List roots (-r) test failed. Expected #{expected}, got #{actual}"
  exit 1
end
