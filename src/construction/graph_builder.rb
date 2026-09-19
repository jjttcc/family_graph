require 'ruby_contracts'
require 'graph_primitives'

# Builds the graph of representations from the Person tree.
# !!!This class might not be needed.
class GraphBuilder
  include Contracts::DSL

  private #!!!forcing an exception - for a reason

  def self.build(people)
    nodes = []
    edges = []
    people.each do |id, person|
      if person.has_spouse then
        # Example: CoupleNode creation logic
        # For this spike, just create PersonNodes for now
      else
        nodes << PersonNode.new(person, Person::SELF)
      end
    end
    [nodes, edges]
  end

end
