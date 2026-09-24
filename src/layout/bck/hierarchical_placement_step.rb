require 'layout_step'
require 'graph_primitives'

# Recursive hierarchical placement
# See "Specifications" in the comments below the class definition.
class HierarchicalPlacementStep < LayoutStep
  include Contracts::DSL

  public

  def execute(context)
    @coords = context.coordinates
    max_gen = context.people.values.map(&:generation).max || 0
    (0..max_gen).each do |gen|
      place_generation(gen, context)
    end
  end

  private

  attr_reader :coords

  def place_generation(gen, context)
    context.people.each_value do |person|
      if person.generation == gen then
        place_person(person, context)
      end
    end
  end

  def place_person(person, context)
    if person.has_spouse then
      place_couple(person, context)
    else
      place_individual(person, context)
    end
  end

  def place_individual(person, context)
    node = coords.node_by_person_id(person.id)
    return if node.x != 0 || node.y != 0
    node.y = person.generation * LEVEL_HEIGHT
    if person.parents.empty? then
      node.x = coords.next_x(node.y)
    else
      parent_node = coords.node_by_person_id(person.parents.first.id)
      node.x = parent_node.x
    end
    coords.update_next_x(node.y, node.x + NODE_WIDTH + SIBLING_SPACING)
  end

  def place_couple(person, context)
    person.spouses.each do |spouse|
      couple_node = coords.node_for_couple(person, spouse)
      if couple_node.nil? || couple_node.x != 0 || couple_node.y != 0 then
        next
      end
      couple_node.y = person.generation * LEVEL_HEIGHT
      if person.parents.empty? && spouse.parents.empty? then
        couple_node.x = coords.next_x(couple_node.y)
      else
        parent_node = coords.node_by_person_id(person.parents.first.id)
        couple_node.x = parent_node.x
      end
      coords.update_next_x(couple_node.y, couple_node.x + 
                           (2 * NODE_WIDTH) + 40 + SIBLING_SPACING)
    end
  end

end

=begin
Specifications:

  - Vertical Strictness: All nodes in a generation g must be placed at an
    identical y coordinate: y = g × LEVEL_HEIGHT.
  - Local Centering (Parent-Child): For any parent (singleton or couple),
    all direct children must be horizontally centered relative to the
    midpoint of the parent(s).
  - Horizontal Determinism: The order of subtrees must be deterministic
    based on the input data.
  - Global Positioning: The initial x coordinate of the root node(s) can be
    determined greedily; global centering is not required at this stage.

=end
