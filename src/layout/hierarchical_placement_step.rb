require 'layout_step'
require 'graph_primitives'

# Implements the recursive placement strategy using node representations.
class HierarchicalPlacementStep < LayoutStep
  include Contracts::DSL

  def execute(context)
    context.roots.each { |root| traverse_and_place(root, context) }
  end

  private

  def traverse_and_place(person, context)
    context.branches(person).each { |child| traverse_and_place(child, context) }
    if person.has_spouse then
      person.spouses.each { |spouse| place_couple(person, spouse, context) }
    else
      place_individual(person, context)
    end
  end

  def place_individual(person, context)
    coords = context.coordinates
    y = person.generation * LEVEL_HEIGHT
    branches = context.branches(person)
    next_x = coords.next_x(y)
    if branches.empty? then
      node = PersonNode.new(person, Person::SELF, next_x, y)
      context.coordinates.add_node(node.person.id, node.x, node.y)
      context.update_person(person, node.x, node.y, Person::SELF)
      coords.update_next_x(y, next_x + NODE_WIDTH + SIBLING_SPACING)
    else
      branch_xs = branches.map { |b| b.self_coordinates[0] }
      midpoint = (branch_xs.min + branch_xs.max) / 2
      parent_x = midpoint
      if parent_x < next_x then
        shift_subtree(person, next_x - parent_x, context)
        parent_x = next_x
      end
      node = PersonNode.new(person, Person::SELF, parent_x, y)
      context.coordinates.add_node(node.person.id, node.x, node.y)
      context.update_person(person, node.x, node.y, Person::SELF)
      coords.update_next_x(y, parent_x + NODE_WIDTH + SIBLING_SPACING)
    end
  end

  def place_couple(p1, p2, context)
    coords = context.coordinates
    y = p1.generation * LEVEL_HEIGHT
    branches = context.branches(p1)
    coords.add_couple(p1.id, p2.id)
    if branches.empty? then
      x1 = coords.next_x(y)
      x2 = x1 + NODE_WIDTH + SIBLING_SPACING
      couple = CoupleNode.new(PersonNode.new(p1, p2.id, x1, y),
                              PersonNode.new(p2, p1.id, x2, y),
                              x1 + (NODE_WIDTH / 2), y)
      context.update_person(p1, x1, y, p2.id)
      context.update_person(p2, x2, y, p1.id)
      coords.update_next_x(y, x2 + NODE_WIDTH + SIBLING_SPACING)
    else
      branch_xs = branches.map { |b| b.self_coordinates[0] }
      midpoint = (branch_xs.min + branch_xs.max) / 2
      parent_x1 = midpoint - (COUPLE_SPACING / 2)
      parent_x2 = parent_x1 + COUPLE_SPACING + NODE_WIDTH
      if parent_x1 < coords.next_x(y) then
        shift_subtree(p1, coords.next_x(y) - parent_x1, context)
        parent_x1 = coords.next_x(y)
        parent_x2 = parent_x1 + COUPLE_SPACING + NODE_WIDTH
      end
      context.update_person(p1, parent_x1, y, p2.id)
      context.update_person(p2, parent_x2, y, p1.id)
      coords.update_next_x(y, parent_x2 + NODE_WIDTH + SIBLING_SPACING)
    end
  end

  def shift_subtree(person, amount, context)
    coords = context.coordinates
    if person then
      person.coordinate_sets.each do |cid, (x, y)|
        new_x = x + amount
        context.update_person(person, new_x, y, cid)
        coords.add_node(person.id, new_x, y)
        coords.update_next_x(y, [coords.next_x(y), new_x + SIBLING_SPACING].max)
      end
      context.branches(person).each { |b| shift_subtree(b, amount, context) }
    end
  end
end
