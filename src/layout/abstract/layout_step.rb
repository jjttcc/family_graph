require 'ruby_contracts'

# The abstract ancestor class for all layout processing steps, using the
# Command pattern.
# Concrete steps must implement the execute method.
class LayoutStep
  include Contracts::DSL

  attr_reader :context

  pre :context_valid do |context| !context.nil? end
  def initialize(context)
    @context = context
  end

  # Executes the layout transformation using the context.
  def execute
    raise NotImplementedError, "#{self.class} must implement #execute"
  end

  protected ### Implementation - utilities

  pre :pvalid do |p| p.is_a?(Person) end
  def shift_subtree(person, amount)
    node = context.coordinates.node_for_person(person)
    if node then
      node.x += amount
    end
    context.branches(person).each { |b| shift_subtree(b, amount) }
  end

  def max_siblings_in_subtree(person)
    counts = Hash.new(0)
    update_sibling_counts(person, counts, 0)
    counts.values.max || 1
  end

  private

  def update_sibling_counts(person, counts, level)
    counts[level] += 1
    context.branches(person).each do |child|
      update_sibling_counts(child, counts, level + 1)
    end
  end

end
