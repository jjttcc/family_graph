# vim: ts=2 sw=2 expandtab
require 'layout_step'
require 'line_crossing_analysis'

# A layout step that analyzes parent-child connection line crossings
# and optimizes sibling or node ordering to minimize edge intersections.
class LineOptimizationStep < LayoutStep
  include Contracts::DSL

  public ###  Initialization

  def initialize(context)
    super(context)
    @analyzer = LineCrossingAnalysis.new
  end

  public ###  Execution

  def execute
    coords = context.coordinates
    crossings = @analyzer.crossing_pairs(coords)
    if ! crossings.empty? then
      puts "LineOptimizationStep detected #{crossings.size} edge crossing(s)."
    else
      puts "LineOptimizationStep: Zero edge crossings detected."
    end
  end

end
