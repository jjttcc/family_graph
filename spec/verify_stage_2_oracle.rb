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
require 'parent'
require 'biological_parent'
require 'non_biological_parent'
require 'graph_primitives'
require 'date'

# Verification script for Stage 2 Oracle
# Runs the pipeline and diffs the candidate against the oracle.

ORACLE_PATH = 'data/oracles/sample_tree_extended_stage_2_oracle.yaml'
CANDIDATE_PATH = 'test/candidates/sample_tree_extended_stage_2_candidate.yaml'
DATA_PATH = 'data/sample_tree_extended.yaml'

# Ensure directories exist
FileUtils.mkdir_p('test/candidates')

# 1. Run the pipeline
puts "Running pipeline on #{DATA_PATH} up to Stage 2..."
system("./bin/family_graph -m ids #{DATA_PATH} -s 2 -o " +
       "/tmp/test_dir -d ancestry -t descendant > /dev/null")

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

permitted = [PersonNode, CoupleNode, Person, Parent, BiologicalParent, NonBiologicalParent, Symbol, Date, Hash]
oracle = YAML.safe_load(File.read(ORACLE_PATH), permitted_classes: permitted, aliases: true)
candidate = YAML.safe_load(File.read(CANDIDATE_PATH), permitted_classes: permitted, aliases: true)

if YAML.dump(oracle) == YAML.dump(candidate)
  puts "SUCCESS: Candidate matches Oracle."
  exit 0
else
  puts "FAILURE: Candidate differs from Oracle."
  exit 1
end
