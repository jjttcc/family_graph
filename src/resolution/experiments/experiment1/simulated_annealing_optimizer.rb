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

# Experimental Simulated Annealing Optimizer for family graph line crossings.
class SimulatedAnnealingOptimizer
  public ###  Execution

  # Initializes with YAML filename, initial temperature, cooling rate, and max steps.
  def initialize(yaml_filename = 'master_tree.yaml', initial_temp = 100.0, cooling_rate = 0.95, max_steps = 50)
    @yaml_filename = yaml_filename
    @initial_temp = initial_temp
    @cooling_rate = cooling_rate
    @max_steps = max_steps
  end

  # Runs the simulated annealing optimization loop, validating via LineCrossingAnalysis.
  def optimize
    yaml_path = File.join(__dir__, 'data', @yaml_filename)
    if !File.exist?(yaml_path) then
      $stderr.puts "YAML file not found: #{yaml_path}"
      exit 1
    end

    puts "Loading tree from #{yaml_filename_display}..."
    people = DataLoader.load(yaml_path)
    root_person = people.values.find { |p| p.father.nil? && p.mother.nil? }
    if !root_person then
      root_person = people.values.first
    end

    coordinates = Coordinates.new
    context = LayoutContext.new(people, [root_person], coordinates, { TRAVERSAL => DESCENDANT })

    analyzer_step = HierarchyAnalyzerStep.new(context)
    analyzer_step.execute

    placement_step = HierarchicalPlacementStep.new(context)
    placement_step.execute

    analyzer = LineCrossingAnalysis.new(coordinates)
    current_crossings = analyzer.crossing_pairs.size
    best_crossings = current_crossings
    best_coordinates_state = Marshal.dump(coordinates)

    puts "Initial Line Crossings: #{current_crossings}"

    temperature = @initial_temp
    step = 0

    while step < @max_steps && current_crossings > 0 do
      # Snapshot current state
      current_snapshot = Marshal.dump(coordinates)
      
      # Generate neighbor mutation using stochastic resolver
      resolver = StochasticSiblingReorderResolution.new(coordinates, step + 123)
      crossings = analyzer.crossing_pairs
      resolver.execute(crossings)

      new_crossings = analyzer.crossing_pairs.size
      delta = new_crossings - current_crossings

      accept = false
      if delta < 0 then
        accept = true
      else
        # Boltzmann acceptance probability for uphill moves
        probability = Math.exp(-delta.to_f / [temperature, 0.001].max)
        if rand < probability then
          accept = true
        end
      end

      if accept then
        current_crossings = new_crossings
        if current_crossings < best_crossings then
          best_crossings = current_crossings
          best_coordinates_state = Marshal.dump(coordinates)
          puts "Step #{step + 1}: New best crossings found = #{best_crossings} (Temp: #{temperature.round(2)})"
        end
      else
        # Rollback
        # Restore coordinates from snapshot via Marshal load assignment
        restored_coords = Marshal.load(current_snapshot)
        coordinates.copy_coordinates_from(restored_coords)
        analyzer.coordinates = coordinates
      end

      temperature *= @cooling_rate
      step += 1
    end

    puts "Optimization Complete. Best Crossings: #{best_crossings}"
    best_crossings
  end

  private ###  Helper Formatting

  def yaml_filename_display
    @yaml_filename
  end

end

if __FILE__ == $0 then
  yaml_file = ARGV[0] || 'master_tree.yaml'
  optimizer = SimulatedAnnealingOptimizer.new(yaml_file, 50.0, 0.90, 30)
  optimizer.optimize
end
