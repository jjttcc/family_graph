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
require 'layout_orchestrator'
require 'family_constants'
require 'layout_pipeline'
require 'hierarchical_placement_step'
require 'compaction_layout_step'
require 'structural_alignment_step'
require 'yaml_oracle_step'
require 'hierarchy_analyzer'

options = {
  root_ids: nil,
  DIRECTION: NONE,
  TRAVERSAL: DESCENDANT,
  output_dir: Dir.pwd,
  label_mode: :dates,
  stop_at_stage: 3 # Default to running full pipeline
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: family_graph <data-path1> ... [options]"
  opts.summary_width = 30
  opts.on("-i", "--root ID1,ID2", Array,
          "Comma-separated list of Root IDs") do |v|
    options[:root_ids] = v
  end
  opts.on("-d", "--direction DIR", "arrow Direction (ancestry/a,",
          "descent/d, none/n)") do |v|
    case v
    when 'a', 'ancestry' then options[DIRECTION] = ANCESTRY
    when 'd', 'descent'  then options[DIRECTION] = DESCENT
    when 'n', 'none'     then options[DIRECTION] = NONE
    else
      puts "Error: Invalid direction '#{v}'. " +
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
    options[:label_mode] = v
  end
  opts.on("-o", "--output DIR", "output directory (default: .)") do |v|
    options[:output_dir] = v
  end
  opts.on("-s", "--stop-at-stage STAGE", Integer,
          "Stop after the specified stage number") do |v|
    options[:stop_at_stage] = v
  end
  opts.on("-l", "--list-all", "list all person IDs") do
    options[:list_all] = true
  end
  opts.on("-r", "--list-roots", "list all Root person IDs") do
    options[:list_roots] = true
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

# Determine if we are just listing IDs
if options[:list_all] || options[:list_roots]
  if ARGV.empty?
    puts "Error: Data file path is required for listing."
    exit 1
  end
  people = {}
  ARGV.each do |path|
    people.merge!(DataLoader.load(path)) if File.exist?(path)
  end
  if options[:list_all]
    puts people.keys.sort
  elsif options[:list_roots]
    roots = people.select do |_id, p|
      p.father.nil? && p.mother.nil?
    end
    puts roots.keys.sort
  end
  exit
end

# Otherwise, positional data paths are mandatory
if ARGV.empty?
  puts "Error: Data file path is required."
  exit 1
end

data_paths = ARGV
people = {}
data_paths.each do |path|
  people.merge!(DataLoader.load(path)) if File.exist?(path)
end

# Calculate generations
ha = HierarchyAnalyzer.new
ha.calculate_and_assign_generations(people)

if options[:root_ids] then
  root_ids = options[:root_ids]
else
  root_ids = people.values.select { |p| p.is_root }.map { |p| p.id }
end

roots = root_ids.map { |id| people[id] }

if roots.empty?
  puts "Warning: No roots to render."
  exit 0
end

# Build pipeline
full_pipeline = [
  HierarchicalPlacementStep.new,
  YamlOracleStep.new("oracle_stage_1.yaml"),
  StructuralAlignmentStep.new,
  YamlOracleStep.new("oracle_stage_2.yaml"),
  CompactionLayoutStep.new,
  YamlOracleStep.new("oracle_stage_3.yaml"),
]

# Truncate pipeline based on stop_at_stage
# Map stages to pipeline indices:
# Stage 1: Index 0, 1
# Stage 2: Index 2, 3
# Stage 3: Index 4, 5
stop_index = case options[:stop_at_stage]
             when 1 then 1
             when 2 then 3
             when 3 then 5
             else 5
             end

layout_pipeline = full_pipeline[0..stop_index]

orchestrator = LayoutOrchestrator.new(roots, people, layout_pipeline, options)
orchestrator.render
