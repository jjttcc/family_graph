require 'ruby_contracts'

# Abstract base class defining the contract for graph layout strategies.
# Concrete subclasses must implement the placement methods.
class LayoutStrategy
  include Contracts::DSL

  # Applies the layout transformation to the entire graph.
  # @param graph [Graph] The graph instance to transform.
  def apply(graph)
    raise NotImplementedError, "#{self.class} must implement #apply"
  end

end
