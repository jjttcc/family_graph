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
require 'person'
require 'graph_primitives'
require 'date'

# Verification script for Stage 1 Oracle
# Runs the pipeline and diffs the candidate against the oracle.

ORACLE_PATH = 'data/oracles/sample_tree_extended_stage_1_oracle.yaml'
CANDIDATE_PATH = 'test/candidates/sample_tree_extended_stage_1_candidate.yaml'
DATA_PATH = 'data/sample_tree_extended.yaml'

# Ensure directories exist
FileUtils.mkdir_p('test/candidates')

# 1. Run the pipeline
# We assume the pipeline writes to the candidate file path.
# Note: We need to ensure YamlOracleStep writes to this path.
# Since we refactored YamlOracleStep to accept a path, we will need 
# a slight tweak in main.rb or a wrapper to point to the candidate file.
# For now, let's run the CLI and move the result.

puts "Running pipeline on #{DATA_PATH}..."
system("./bin/family_graph -m ids #{DATA_PATH} -o " +
       "/tmp/test_dir -d ancestry -t descendant > /dev/null")

# Move the generated oracle_stage_1.yaml to the candidate location
if File.exist?('oracle_stage_1.yaml')
  FileUtils.mv('oracle_stage_1.yaml', CANDIDATE_PATH)
else
  puts "Failure: Pipeline did not generate oracle_stage_1.yaml"
  exit 1
end

# 2. Perform the diff
puts "Comparing candidate against oracle..."
permitted = [PersonNode, CoupleNode, Person, Symbol, Date, Hash]
oracle = YAML.safe_load(File.read(ORACLE_PATH), permitted_classes: permitted, aliases: true)
candidate = YAML.safe_load(File.read(CANDIDATE_PATH), permitted_classes: permitted, aliases: true)
if oracle == candidate then

  puts "SUCCESS: Candidate matches Oracle."
  exit 0
else
  puts "FAILURE: Candidate differs from Oracle."
  # Optional: print specific diff here if needed
  exit 1
end
