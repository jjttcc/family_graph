# vim: ts=2 sw=2 expandtab
#!/usr/bin/env ruby

root = 'FG_ROOT'
root_path = ENV[root]
setup_path = "#{root_path}/setup.rb"
if ! ENV[root] then
  $stderr.puts "environment variable #{root} must be set."
  exit 2
end
require setup_path
require 'coordinates'
require 'line_crossing_analysis'
require 'line_crossing_resolution'
require 'node_swap_resolution'
require 'sibling_reorder_resolution'
require_relative 'stochastic_sibling_reorder_resolution'
require 'data_loader'
require 'layout_context'
require 'layout_pipeline'
require 'hierarchy_analyzer_step'
require 'hierarchical_placement_step'

# Experimental runner for stochastic multi-start trials on data YAML trees.
class ExperimentRunner
  public ###  Execution

  # Runs multiple randomized trials on sample tree YAML data.
  def run_yaml_trials(yaml_filename = 'sample_tree_line_crossing.yaml', trial_count = 5)
    yaml_path = File.join(__dir__, '..', '..', '..', 'data', yaml_filename)
    if !File.exist?(yaml_path) then
      $stderr.puts "YAML file not found: #{yaml_path}"
      exit 1
    end

    puts "Running #{trial_count} stochastic trials on #{yaml_filename}..."
    success_count = 0
    min_crossings_found = Float::INFINITY

    trial_count.times do |index|
      seed = index + 100
      people = DataLoader.load(yaml_path)
      root_person = people.values.find { |p| p.father.nil? && p.mother.nil? }
      coordinates = Coordinates.new
      context = LayoutContext.new(people, [root_person], coordinates, { TRAVERSAL => DESCENDANT })

      # Run hierarchical placement to set up initial layout coordinates
      placement_step = HierarchicalPlacementStep.new(context)
      placement_step.execute

      analyzer = LineCrossingAnalysis.new(coordinates)
      initial_crossings = analyzer.crossing_pairs.size

      resolver = StochasticSiblingReorderResolution.new(coordinates, seed)
      crossings = analyzer.crossing_pairs
      resolver.execute(crossings)
      final_crossings = analyzer.crossing_pairs.size

      if final_crossings < min_crossings_found then
        min_crossings_found = final_crossings
      end

      if final_crossings == 0 then
        success_count += 1
      end

      puts "Trial #{index + 1}: Initial crossings = #{initial_crossings}, Final crossings = #{final_crossings} (Seed: #{seed})"
    end

    puts "YAML Experiment Summary: Successes = #{success_count}/#{trial_count}, Min crossings = #{min_crossings_found}"
  end

end

if __FILE__ == $0 then
  runner = ExperimentRunner.new
  runner.run_yaml_trials('sample_tree_line_crossing.yaml', 5)
end
