require 'layout_step'
require 'graph_primitives'

# New HierarchicalPlacementStep using the Representation-based architecture.
class HierarchicalPlacementStep < LayoutStep
  include Contracts::DSL

  public

  def execute(context)
    # This implementation is a stub to demonstrate the design
    # It assumes LayoutContext will be updated to support add_node
    # which will store the PersonNode/CoupleNode instances.
    roots = context.roots
    roots.each do |root|
      place_node(root, context, 0, 0)
    end
  end

  private

  # Recursively places a person and their descendants in the coordinate registry.
  # This is a procedural traversal that populates coordinate_sets.
  def place_node(person, context, x, y, processed_couples = Set.new)
    if person.has_spouse then
      person.spouses.each do |spouse|
        couple_id = [person.id, spouse.id].sort
        if processed_couples.include?(couple_id) then
          next
        end
        p1 = PersonNode.new(person, spouse.id, x, y)
        p2 = PersonNode.new(spouse, person.id, x + 100, y)
        couple = CoupleNode.new(p1, p2, x + 50, y)
        context.update_person(p1.person, p1.x, p1.y, p1.context_id)
        context.update_person(p2.person, p2.x, p2.y, p2.context_id)
        context.branches(person).each do |child|
          place_node(child, context, couple.x, couple.y + 100, processed_couples)
        end
        processed_couples.add(couple_id)
      end
    else
      node = PersonNode.new(person, Person::SELF, x, y)
      context.update_person(node.person, node.x, node.y, node.context_id)
      context.branches(person).each do |child|
        place_node(child, context, node.x, node.y + 100, processed_couples)
      end
    end
  end

end
