#!/usr/bin/env ruby
# Master test script to run all regression and functional tests.

ENV['ENABLE_ASSERTION'] = '1'
test_scripts = ["regression_test.rb", "test_suite.rb", "cli_regression.rb"]

all_passed = true

test_scripts.each do |script|
  puts "=== Running #{script} ==="
  system("ruby spec/#{script}")
  if $?.success?
    puts "SUCCESS: #{script}\n\n"
  else
    puts "FAILURE: #{script}\n\n"
    all_passed = false
  end
end

if all_passed
  puts "ALL TESTS PASSED"
  exit 0
else
  puts "SOME TESTS FAILED"
  exit 1
end
