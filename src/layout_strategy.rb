require 'ruby_contracts'

# Abstract base class defining the contract for graph layout strategies.
# Concrete subclasses must implement the placement methods.
class LayoutStrategy
  include Contracts::DSL

  public ### Abstract Interface (to be implemented by subclasses)

  # Add coordinates for an individual person.
  # @param person [Person] The person to place
  # @param graph [Graph] The graph context
  pre :person_valid do |person, graph| !person.nil? && !graph.nil? end
  def add_individual(person, graph)
    raise NotImplementedError, "#{self.class} must implement #add_individual"
  end

  # Add coordinates for a couple.
  # @param spouse1 [Person]
  # @param spouse2 [Person]
  # @param graph [Graph]
  pre :spouses_valid do |spouse1, spouse2, graph|
    !spouse1.nil? && !spouse2.nil? && !graph.nil?
  end
  def add_couple(spouse1, spouse2, graph)
    raise NotImplementedError, "#{self.class} must implement #add_couple"
  end

  # Shift a subtree of nodes.
  # @param person [Person]
  # @param amount [Numeric]
  # @param graph [Graph]
  pre :params_valid do |person, amount, graph|
    !person.nil? && amount.is_a?(Numeric) && !graph.nil?
  end
  def shift_subtree(person, amount, graph)
    raise NotImplementedError, "#{self.class} must implement #shift_subtree"
  end

end
