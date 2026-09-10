require_relative 'layout_strategy'

# A composite strategy that delegates layout operations to a sequence of 
# individual layout strategy components.
class CompositeLayoutStrategy < LayoutStrategy
  include Contracts::DSL

  public

  def initialize(strategies = [])
    @strategies = strategies
  end

  def add_individual(person, graph)
    @strategies.each { |s| s.add_individual(person, graph) }
  end

  def add_couple(spouse1, spouse2, graph)
    @strategies.each { |s| s.add_couple(spouse1, spouse2, graph) }
  end

  def shift_subtree(person, amount, graph)
    @strategies.each { |s| s.shift_subtree(person, amount, graph) }
  end

  def compact(graph, people)
    @strategies.each { |s| s.compact(graph, people) if s.respond_to?(:compact) }
  end

  def align(graph, people)
    @strategies.each { |s| s.align(graph, people) if s.respond_to?(:align) }
  end

end
