# vim: ts=2 sw=2 expandtab
require 'layout_step'
require 'line_crossing_analysis'
require 'line_crossing_resolution'
require 'node_swap_resolution'
require 'sibling_reorder_resolution'

# A layout step that analyzes parent-child connection line crossings
# and optimizes sibling or node ordering to minimize edge intersections.
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

  def execute
    max_resolvers = @resolvers.size
    if ENV['FG_MAX_RESOLVERS'] then
      env_max = ENV['FG_MAX_RESOLVERS'].to_i
      if env_max < max_resolvers then
        max_resolvers = env_max
      end
    end
    crossings = analyzer.crossing_pairs
    max_iterations = 10
    iteration = 0
    while !crossings.empty? && iteration < max_iterations do
      (0..(max_resolvers - 1)).each do |i|
        if !crossings.empty? then
          resolver = @resolvers[i]
          if resolver then
            # (puts lines are for debugging - need to be removed.)
            msg = "LineOptimizationStep: running #{resolver.class.name} " +
                "(iteration #{iteration + 1}, crossings: #{crossings.size})"
            puts msg
            resolver.execute(crossings)
            crossings = analyzer.crossing_pairs
          end
        end
      end
      iteration += 1
    end
    if crossings.empty? then
      puts "LineOptimizationStep: Zero edge crossings detected."
    else
      msg = "LineOptimizationStep: Reached max iterations " +
        "(#{max_iterations}) with #{crossings.size} remaining crossing(s)."
      puts msg
    end
  end

  private ###  Implementation

  attr_reader :analyzer, :resolvers

end
