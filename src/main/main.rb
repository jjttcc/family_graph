#!/usr/bin/env ruby

root = 'FG_ROOT'
setup_path = ENV[root] + '/setup.rb'
if ! ENV[root] then
  $stderr.puts "environment variable #{root} must be set."
  exit 2
end
require setup_path
require 'debug'
require 'optparse'
require 'data_loader'
require 'coordinates'
require 'layout_context'
require 'layout_orchestrator'
require 'family_constants'
require 'layout_pipeline'
require 'hierarchy_analyzer_step'
require 'node_creator_step'
require 'width_calculator_step'
require 'hierarchical_placement_step'
require 'line_optimization_step'
require 'yaml_oracle_step'

options = {
  ROOT_IDS        => nil,
  DIRECTION       => NONE,
  TRAVERSAL       => DESCENDANT,
  OUTPUT_DIR      => Dir.pwd,
  LABEL_MODE      => DATES,
  STOP_AT_STAGE   => 3 # Default to running full pipeline
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: family_graph <data-path1> ... [options]"
  opts.summary_width = 30
  opts.on("-i", "--root ID1,ID2", Array,
          "Comma-separated list of Root IDs") do |v|
    options[ROOT_IDS] = v
  end
  opts.on("-d", "--direction DIR", "arrow Direction (ancestry/a,",
          "descent/d, none/n)") do |v|
    case v
    when 'a', 'ancestry' then options[DIRECTION] = ANCESTRY
    when 'd', 'descent'  then options[DIRECTION] = DESCENT
    when 'n', 'none'     then options[DIRECTION] = NONE
    else
      $stderr.puts "Error: Invalid direction '#{v}'. " +
        "Use ancestry/a, descent/d, or none/n."
      exit 1
    end
  end
  opts.on("-t", "--traversal TYPE", [ANCESTOR, DESCENDANT],
          "traversal type (ancestor/descendant)") do |v|
    options[TRAVERSAL] = v
  end
  opts.on("-m", "--label-mode MODE", [:dates, :ids, :both],
          "label mode (dates, ids, both)") do |v|
    options[LABEL_MODE] = v
  end
  opts.on("-o", "--output DIR", "output directory (default: .)") do |v|
    options[OUTPUT_DIR] = v
  end
  opts.on("-s", "--stop-at-stage STAGE", Integer,
          "Stop after the specified stage number") do |v|
    options[STOP_AT_STAGE] = v
  end
  opts.on("-l", "--list-all", "list all person IDs") do
    options[LIST_ALL] = true
  end
  opts.on("-r", "--list-roots", "list all Root person IDs") do
    options[LIST_ROOTS] = true
  end
  opts.on("-h", "--help", "show this help message") do
    puts opts
    exit
  end
  opts.on("-v", "--version", "show application version") do
    puts VERSION
    exit
  end
end

parser.parse!

people = {}
# Determine if we are just listing IDs
if options[LIST_ALL] || options[LIST_ROOTS] then
  if ARGV.empty? then
    $stderr.puts "Error: Data file path is required for listing."
    exit 1
  end
  ARGV.each do |path|
    if File.exist?(path) then
      people.merge!(DataLoader.load(path))
    else
      $stderr.puts "Warning: #{path} does not exist."
    end
  end
  if options[LIST_ALL] then
    puts people.keys.sort
  elsif options[LIST_ROOTS] then
    roots = people.select do |_id, p|
      p.father.nil? && p.mother.nil?
    end
    puts roots.keys.sort
  end
  exit
end

# Otherwise, positional data paths are mandatory
if ARGV.empty? then
  $stderr.puts "Error: Data file path is required."
  exit 1
end

data_paths = ARGV
data_paths.each do |path|
  if File.exist?(path) then
    people.merge!(DataLoader.load(path))
  else
    $stderr.puts "Warning: #{path} does not exist."
  end
end

if options[ROOT_IDS] then
  root_ids = options[ROOT_IDS]
else
  root_ids = people.values.select { |p| p.is_root }.map { |p| p.id }
end

roots = root_ids.map { |id| people[id] }

if roots.empty?
  puts "Warning: No roots to render."
  exit 0
end

coordinates = Coordinates.new
context = LayoutContext.new(people, roots, coordinates, options)

# Build pipeline
full_pipeline = [
  HierarchyAnalyzerStep.new(context),
  NodeCreatorStep.new(context),
  WidthCalculatorStep.new(context),
  HierarchicalPlacementStep.new(context),
  YamlOracleStep.new("oracle_stage_1.yaml", context),
  LineOptimizationStep.new(context),
  YamlOracleStep.new("oracle_stage_2.yaml", context),
#  OverlapEliminationStep.new(context),
#  YamlOracleStep.new("oracle_stage_3.yaml", context),
]

# Map stages to pipeline indices:
# Stage 1: Index 0, 1, 2, 3, 4
# Stage 2: Index 5, 6
# Stage 3: Index 7, 8
stop_index = case options[STOP_AT_STAGE]
             when 1 then 4
             when 2 then 6
             when 3 then 8
             else 8
             end

layout_pipeline = full_pipeline[0..stop_index]

orchestrator = LayoutOrchestrator.new(layout_pipeline, context)
orchestrator.render
