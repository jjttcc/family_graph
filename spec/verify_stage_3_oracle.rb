#!/usr/bin/env ruby

root = 'FG_ROOT'
root_path = ENV[root]
setup_path = "#{root_path}/setup.rb"
if ! ENV[root] then
  $stderr.puts "environment variable #{root} must be set."
  exit 2
end
require setup_path
require 'yaml'
require 'fileutils'

# Verification script for Stage 3 Oracle
# Runs the pipeline and diffs the candidate against the oracle.

ORACLE_PATH = 'data/oracles/sample_tree_extended_stage_3_oracle.yaml'
CANDIDATE_PATH = 'test/candidates/sample_tree_extended_stage_3_candidate.yaml'
DATA_PATH = 'data/sample_tree_extended.yaml'

# Ensure directories exist
FileUtils.mkdir_p('test/candidates')

# 1. Run the pipeline
puts "Running pipeline on #{DATA_PATH} up to Stage 3..."
system("./bin/family_graph -m ids #{DATA_PATH} -s 3 -o " +
       "/tmp/test_dir -d ancestry -t descendant > /dev/null")

# Move the generated candidate to the test/candidates location
if File.exist?('oracle_stage_3.yaml')
  FileUtils.mv('oracle_stage_3.yaml', CANDIDATE_PATH)
else
  puts "Failure: Pipeline did not generate oracle_stage_3.yaml"
  exit 1
end

# 2. Perform the diff
puts "Comparing candidate against oracle..."

if !File.exist?(ORACLE_PATH)
  puts "Failure: Oracle file #{ORACLE_PATH} not found. Please create it first."
  exit 1
end

oracle = YAML.load_file(ORACLE_PATH)
candidate = YAML.load_file(CANDIDATE_PATH)

if oracle == candidate
  puts "SUCCESS: Candidate matches Oracle."
  exit 0
else
  puts "FAILURE: Candidate differs from Oracle."
  exit 1
end
