#!/usr/bin/env ruby

require 'debug'
require 'optparse'
require_relative 'data_loader'
require_relative 'layout_orchestrator'
require_relative 'family_constants'
require_relative 'layout_pipeline'
require_relative 'hierarchical_placement_step'
require_relative 'compaction_layout_step'
require_relative 'structural_alignment_step'
require_relative 'yaml_oracle_step'
require_relative 'hierarchy_analyzer'

options = {
  root_ids: nil,
  direction: :none,
  traversal: :descendant,
  output_dir: Dir.pwd,
  label_mode: :dates
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: family_graph <data-path1> ... [options]"
  opts.summary_width = 30
  opts.on("-i", "--root ID1,ID2", Array,
          "Comma-separated list of Root IDs",
          "({all} for all roots)") do |v|
    options[:root_ids] = v
  end
  opts.on("-d", "--direction DIR", "arrow Direction (ancestry/a,",
          "descent/d, none/n)") do |v|
    case v
    when 'a', 'ancestry' then options[:direction] = :ancestry
    when 'd', 'descent'  then options[:direction] = :descent
    when 'n', 'none'     then options[:direction] = :none
    else
      puts "Error: Invalid direction '#{v}'. " +
        "Use ancestry/a, descent/d, or none/n."
      exit 1
    end
  end
  opts.on("-t", "--traversal TYPE", [:ancestor, :descendant],
          "traversal type (ancestor/descendant)") do |v|
    options[:traversal] = v
  end
  opts.on("-m", "--label-mode MODE", [:dates, :ids, :both],
          "label mode (dates, ids, both)") do |v|
    options[:label_mode] = v
  end
  opts.on("-o", "--output DIR", "output directory (default: .)") do |v|
    options[:output_dir] = v
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
  puts "Error: No roots to render."
  exit 1
end

# Build pipeline
layout_pipeline = [
  HierarchicalPlacementStep.new,
#  StructuralAlignmentStep.new,
#  CompactionLayoutStep.new,
  YamlOracleStep.new("oracle_stage_1.yaml")
]

orchestrator = LayoutOrchestrator.new(roots, people, layout_pipeline, options)
orchestrator.render
