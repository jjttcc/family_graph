require 'layout_step'
require 'graph_primitives'

# Recursive hierarchical placement
# See "Specifications" in the comments below the class definition.
class HierarchicalPlacementStep < LayoutStep
  include Contracts::DSL

  public

  def execute(context)
    @coords = context.coordinates
    processed_nodes = Set.new
    context.roots.each do |root|
      place_node(root, context, root.generation * LEVEL_HEIGHT,
                 Set.new, processed_nodes)
    end
  end

  private

  attr_reader :coords

  # Recursively places a person and their descendants.
  def place_node(person, context, y, processed_couples = Set.new,
                 processed_nodes = Set.new)
    if !processed_nodes.include?(person.id) then
      processed_nodes.add(person.id)
      DebugLogger.log("DEBUG: Placing #{person.id} at Y=#{y}")
      if person.has_spouse then
        place_couple(person, context, y, processed_couples, processed_nodes)
      else
        place_individual(person, context, y, processed_couples, processed_nodes)
      end
    end
  end
def place_individual(person, context, y, processed_couples, processed_nodes)
  branches = context.branches(person)
  next_x = coords.next_x(y)
  node = coords.node_by_person_id(person.id)
  if branches.empty? then
    node.x = next_x
    node.y = y
    coords.update_next_x(y, next_x + NODE_WIDTH + SIBLING_SPACING)
  else
    branches.each do |b|
      place_node(b, context, y + LEVEL_HEIGHT, processed_couples,
                 processed_nodes)
    end
    branch_xs = branches.map do |b|
      child_node = coords.node_for_person(b)
      child_node ? child_node.x : 0
    end
    midpoint = (branch_xs.min + branch_xs.max) / 2
    DebugLogger.log("DEBUG: Individual #{person.id} branches: " \
                    "#{branches.map(&:id).join(',')}, " \
                    "branch_xs: #{branch_xs.join(',')}, Mid: #{midpoint}")
    node.x = midpoint
    node.y = y
    coords.update_next_x(y, [next_x, node.x + NODE_WIDTH + 
                         SIBLING_SPACING].max)
  end
  end

  def place_couple(person, context, y, processed_couples, processed_nodes)
    person.spouses.each do |spouse|
      couple_id = [person.id, spouse.id].sort
      if !processed_couples.include?(couple_id) then
        branches = context.branches(person)
        branches.each do |b|
          place_node(b, context, y + LEVEL_HEIGHT, processed_couples,
                     processed_nodes)
        end
        couple_node = coords.couple(couple_id.join('.'))
        p1 = couple_node.partner_a
        p2 = couple_node.partner_b
        branch_xs = branches.map do |b|
          child_node = coords.node_by_person_id(b.id)
          child_node ? child_node.x : 0
        end
        midpoint = branch_xs.empty? ? coords.next_x(y) :
                                      (branch_xs.min + branch_xs.max) / 2
        x = midpoint - (COUPLE_SPACING / 2)
        p1.x = x
        p1.y = y
        p2.x = x + NODE_WIDTH + 20
        p2.y = y
        couple_node.x = x + 50
        couple_node.y = y
        coords.update_next_x(y, [coords.next_x(y), x + (2 * NODE_WIDTH) + 40 +
                             SIBLING_SPACING].max)
        processed_couples.add(couple_id)
      end
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
