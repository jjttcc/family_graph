require_relative 'layout_strategy'

# A simple, flat pipeline that delegates layout operations to a sequence
# of individual layout strategy components.
class LayoutPipeline < LayoutStrategy
  def initialize(strategies = [])
    @strategies = strategies
  end

  def apply(graph)
    @strategies.each { |s| s.apply(graph) }
  end

  def shift_subtree(person, amount, graph)
    @strategies.each { |s| s.shift_subtree(person, amount, graph) if s.respond_to?(:shift_subtree) }
  end
end
