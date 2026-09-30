# vim: ts=2 sw=2 expandtab
require 'layout_step'
require 'line_crossing_analysis'
require 'line_crossing_resolution'
require 'node_swap_resolution'
require 'sibling_reorder_resolution'

# A layout step that analyzes parent-child connection line crossings
# and optimizes sibling or node ordering to minimize edge intersections
# using an iterative greedy best-first search with coordinate rollback
# and single instance reuse for analyzer and resolvers.
class LineOptimizationStep < LayoutStep
  include Contracts::DSL

  public ###  Initialization

  def initialize(context)
    super(context)
    @analyzer = LineCrossingAnalysis.new(context.coordinates)
    @resolvers = [
      NodeSwapResolution.new(context.coordinates),
      SiblingReorderResolution.new(context.coordinates)
    ]
  end

  public ###  Execution

  # Executes the iterative greedy best-first line optimization algorithm
  # using coordinate snapshotting, rollback, and single instance reuse.
  def execute
    current_crossings = analyzer.crossing_pairs.size
    if current_crossings > 0 then
      max_iterations = 20
      iteration = 0
      continue_optimization = true
      while continue_optimization && current_crossings > 0 &&
            iteration < max_iterations do
        best_resolver = nil
        best_crossings = current_crossings
        best_mutated_coords = nil
        resolvers.each do |resolver|
          test_coords = Marshal.load(Marshal.dump(context.coordinates))
          analyzer.coordinates = test_coords
          resolver.coordinates = test_coords
          test_crossings_pairs = analyzer.crossing_pairs
          resolver.execute(test_crossings_pairs)
          new_crossings = analyzer.crossing_pairs.size
          if new_crossings < best_crossings then
            best_crossings = new_crossings
            best_resolver = resolver
            best_mutated_coords = test_coords
          end
        end
        if best_resolver && best_crossings < current_crossings then
          context.coordinates.copy_coordinates_from(best_mutated_coords)
          reset_coordinates(context.coordinates)
          current_crossings = best_crossings
          iteration += 1
          msg = "LineOptimizationStep: Applied #{best_resolver.class.name}, " +
                "remaining crossings: #{current_crossings}"
          puts msg
        else
          reset_coordinates(context.coordinates)
          continue_optimization = false
        end
      end
      report_completion(current_crossings)
    else
      puts "LineOptimizationStep: Zero edge crossings detected."
    end
  end

  private ###  Implementation

  attr_reader :analyzer, :resolvers

  # Resets coordinates for analyzer and all resolvers to the given registry.
  def reset_coordinates(target_coordinates)
    analyzer.coordinates = target_coordinates
    resolvers.each do |resolver|
      resolver.coordinates = target_coordinates
    end
  end

  # Reports the final optimization status.
  def report_completion(final_crossings)
    if final_crossings == 0 then
      puts "LineOptimizationStep: Zero edge crossings detected."
    else
      msg = "LineOptimizationStep: Optimization completed with " +
            "#{final_crossings} remaining crossing(s)."
      puts msg
    end
  end

end
