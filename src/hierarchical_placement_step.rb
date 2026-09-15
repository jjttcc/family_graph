# vim: ts=2 sw=2 expandtab
require_relative 'debug_logger'
require_relative 'layout_step'
require_relative 'family_constants'

# Implements the recursive placement strategy.
class HierarchicalPlacementStep < LayoutStep
  include Contracts::DSL

  def execute(context)
    # The context holds the roots
    context.roots.each do |root|
      traverse_and_place(root, context)
    end
  end

  private

  def traverse_and_place(person, context)
    # Recursively traverse branches first
    context.branches(person).each do |child|
      traverse_and_place(child, context)
    end
    if person.has_spouse then
      person.spouses.each do |spouse|
        place_couple(person, spouse, context)
      end
    else
      place_individual(person, context)
    end
  end

  def place_individual(person, context)
    coordinates = context.coordinates
    y = person.generation * LEVEL_HEIGHT
    branches = context.branches(person)
    current_next_x = coordinates.next_x(y)
    if branches.empty? then
      x = current_next_x
      DebugLogger.log("DEBUG: Placing #{person.id} at X=#{x}, Y=#{y}.")
      context.update_person(person, x, y)
      coordinates.update_next_x(y, x + SIBLING_SPACING)
    else
      # Center over branches
      branch_xs = branches.map { |br| br.self_coordinates[0] }
      midpoint = (branch_xs.min + branch_xs.max) / 2
      parent_x = midpoint
      DebugLogger.log("DEBUG: Placing #{person.id} at X=#{parent_x}, Y=#{y}.")
      if parent_x < current_next_x then
        shift_amount = current_next_x - parent_x
        shift_subtree(person, shift_amount, context)
        parent_x = current_next_x
      end
      context.update_person(person, parent_x, y)
      coordinates.update_next_x(y, parent_x + SIBLING_SPACING)
    end
  end

  def place_couple(spouse1, spouse2, context)
    coordinates = context.coordinates
    y = spouse1.generation * LEVEL_HEIGHT
    branches = context.branches(spouse1)
    coordinates.add_couple(spouse1.id, spouse2.id)
    if branches.empty? then
      x1 = coordinates.next_x(y)
      x2 = x1 + COUPLE_SPACING
      context.update_person(spouse1, x1, y, spouse2.id)
      context.update_person(spouse2, x2, y, spouse1.id)
      coordinates.update_next_x(y, x2 + SIBLING_SPACING)
    else
      # Center over branches
      branch_xs = branches.map { |b| b.self_coordinates[0] }
      midpoint = (branch_xs.min + branch_xs.max) / 2
      parent_x1 = midpoint - (COUPLE_SPACING / 2)
      parent_x2 = parent_x1 + COUPLE_SPACING
      if parent_x1 < coordinates.next_x(y) then
        shift_amount = coordinates.next_x(y) - parent_x1
        shift_subtree(spouse1, shift_amount, context)
        parent_x1 = coordinates.next_x(y)
        parent_x2 = parent_x1 + COUPLE_SPACING
      end
      context.update_person(spouse1, parent_x1, y, spouse2.id)
      context.update_person(spouse2, parent_x2, y, spouse1.id)
      coordinates.update_next_x(y, parent_x2 + SIBLING_SPACING)
    end
  end

  def shift_subtree(person, amount, context)
    coordinates = context.coordinates
    if ! person.nil? then
      # Update all existing coordinate sets for this person
      person.coordinate_sets.each do |context_id, (x, y)|
        new_x = x + amount
        context.update_person(person, new_x, y, context_id)
        coordinates.add_node(person.id, new_x, y)
        coordinates.update_next_x(y, [
          coordinates.next_x(y), new_x + SIBLING_SPACING].max)
      end
      context.branches(person).each do |branch|
        shift_subtree(branch, amount, context)
      end
    end
  end

end
