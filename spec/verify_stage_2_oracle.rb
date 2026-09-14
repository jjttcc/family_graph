#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'

# Verification script for Stage 2 Oracle
# Runs the pipeline and diffs the candidate against the oracle.

ORACLE_PATH = 'data/oracles/sample_tree_extended_stage_2_oracle.yaml'
CANDIDATE_PATH = 'test/candidates/sample_tree_extended_stage_2_candidate.yaml'
DATA_PATH = 'data/sample_tree_extended.yaml'

# Ensure directories exist
FileUtils.mkdir_p('test/candidates')

# 1. Run the pipeline
puts "Running pipeline on #{DATA_PATH} up to Stage 2..."
system("./bin/family_graph -m ids #{DATA_PATH} -s 2 -o /tmp/test_dir -d ancestry -t descendant > /dev/null")

# Move the generated candidate to the test/candidates location
# Note: YamlOracleStep currently writes to hardcoded files based on name.
# We need to ensure the correct file is captured.
if File.exist?('oracle_stage_2.yaml')
  FileUtils.mv('oracle_stage_2.yaml', CANDIDATE_PATH)
else
  puts "Failure: Pipeline did not generate oracle_stage_2.yaml"
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
