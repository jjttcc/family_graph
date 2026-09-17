#!/usr/bin/env ruby
# Test the '-r' list-roots functionality

root = 'FG_ROOT'
root_path = ENV[root]
setup_path = "#{root_path}/setup.rb"
if ! ENV[root] then
  $stderr.puts "environment variable #{root} must be set."
  exit 2
end
require setup_path
# Run main.rb -r
reader, writer = IO.pipe
pid = fork do
  reader.close
  $stdout.reopen(writer)
  exec("ruby", "src/main/main.rb", "-r", "data/sample_tree.yaml")
end
writer.close
output = reader.read
Process.wait(pid)

# Roots should be nodes with no father and no mother
expected = ["bob_doe_101", "frank_smith_301", "root_ancestor_100",
            "spouse_1", "spouse_2"].sort
actual = output.split("\n").sort

if actual == expected
  puts "List roots (-r) test PASSED!"
  exit 0
else
  puts "List roots (-r) test FAILED. Expected #{expected}, got #{actual}"
  exit 1
end
