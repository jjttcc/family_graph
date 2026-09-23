require 'layout_step'
require 'graph_primitives'

# Instantiates all PersonNode and CoupleNode instances in the registry
# before layout steps perform centering or alignment.
class NodeCreatorStep < LayoutStep
  include Contracts::DSL

  public

  def execute(context)
    coords = context.coordinates
    context.people.each_value do |person|
      if !person.has_spouse then
        node = PersonNode.new(person, 0, 0)
        coords.add_single_node(node)
      else
        process_couple(person, context)
      end
    end
  end

  private

  def process_couple(person, context)
    person.spouses.each do |spouse|
      couple_id = [person.id, spouse.id].sort
      if !context.coordinates.couples.key?(couple_id.join('.')) then
        p1 = PersonNode.new(person, 0, 0)
        p2 = PersonNode.new(spouse, 0, 0)
        couple = CoupleNode.new(p1, p2, 0, 0)
        context.coordinates.add_couple(couple)
      end
    end
  end
end
