require 'layout_step'
require 'graph_primitives'

# Implements the recursive placement strategy using node representations.
class HierarchicalPlacementStep < LayoutStep
  include Contracts::DSL

  public

  def execute(context)
    @coords = context.coordinates
    context.roots.each do |root|
      place_node(root, context, root.generation * LEVEL_HEIGHT)
    end
  end

  private

  attr_reader :coords

  # Recursively places a person and their descendants.
  def place_node(person, context, y, processed_couples = Set.new)
    if person.has_spouse then
      place_couple(person, context, y, processed_couples)
    else
      place_individual(person, context, y, processed_couples)
    end
  end

  def place_individual(person, context, y, processed_couples)
    branches = context.branches(person)
    next_x = coords.next_x(y)
    if branches.empty? then
      x = next_x
      node = PersonNode.new(person, x, y)
      coords.add_node(node)
      coords.update_next_x(y, x + NODE_WIDTH + SIBLING_SPACING)
    else
      branch_xs = branches.map do |b|
        node = coords.node_for_person(b)
        node ? node.x : 0
      end
      midpoint = (branch_xs.min + branch_xs.max) / 2
      x = midpoint
      if x < next_x then
        shift_subtree(person, next_x - x, context)
        x = next_x
      end
      node = PersonNode.new(person, x, y)
      coords.add_node(node)
      coords.update_next_x(y, x + NODE_WIDTH + SIBLING_SPACING)
    end
    branches.each { |b| place_node(b, context, y + 100, processed_couples) }
    node
  end

  def place_couple(person, context, y, processed_couples)
    person.spouses.each do |spouse|
      couple_id = [person.id, spouse.id].sort
      if processed_couples.include?(couple_id) then
        next
      end
      branches = context.branches(person)
      if branches.empty? then
        x = coords.next_x(y)
        p1 = PersonNode.new(person, x, y)
        p2 = PersonNode.new(spouse, x + NODE_WIDTH + 20, y)
        couple = CoupleNode.new(p1, p2, x + 50, y)
        coords.add_couple(couple)
        coords.update_next_x(y, x + (2 * NODE_WIDTH) + 40 + SIBLING_SPACING)
      else
        branch_xs = branches.map do |b|
          node = coords.node(b.id)
          if node.nil? then
            DebugLogger.log("DEBUG: Node not found for #{b.id}")
            0
          else
            node.x
          end
        end
        midpoint = (branch_xs.min + branch_xs.max) / 2
        x = midpoint - (COUPLE_SPACING / 2)
        if x < coords.next_x(y) then
          shift_subtree(person, coords.next_x(y) - x, context)
          x = coords.next_x(y)
        end
        p1 = PersonNode.new(person, x, y)
        p2 = PersonNode.new(spouse, x + NODE_WIDTH + 20, y)
        couple = CoupleNode.new(p1, p2, x + 50, y)
        coords.add_couple(couple)
        coords.update_next_x(y, x + (2 * NODE_WIDTH) + 40 + SIBLING_SPACING)
      end
      branches.each { |b| place_node(b, context, y + 100, processed_couples) }
      processed_couples.add(couple_id)
      return couple
    end
  end

  def shift_subtree(person, amount, context)
    if person then
      person.coordinate_sets.each do |cid, (x, y)|
        new_x = x + amount
        if coords.has_node?(person.id) then
          node = coords.node(person.id)
          node.x = new_x
        end
        coords.update_next_x(y, [coords.next_x(y),
                                 new_x + NODE_WIDTH + SIBLING_SPACING].max)
      end
      context.branches(person).each { |b| shift_subtree(b, amount, context) }
    end
  end
end
