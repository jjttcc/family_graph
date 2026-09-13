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
    context.branches(person).each { |child| traverse_and_place(child, context) }

    if person.has_spouse
      place_couple(person, person.spouse, context)
    else
      place_individual(person, context)
    end
  end

  def place_individual(person, context)
    coordinates = context.coordinates
    y = person.generation * LEVEL_HEIGHT
    branches = context.branches(person)
    current_next_x = coordinates.next_x(y)
    
    if branches.empty?
      x = current_next_x
      DebugLogger.log("DEBUG: Placing #{person.id} (OID: #{person.object_id}) at X=#{x}, Y=#{y}. Next_x was #{current_next_x}")
      person.add_coordinate_set(x, y, nil)
      coordinates.add_node(person.id, x, y)
      coordinates.update_next_x(y, x + SIBLING_SPACING)
    else
      # Center over branches
      branch_xs = branches.map { |br| br.coordinate_set(nil)[0] }
      midpoint = (branch_xs.min + branch_xs.max) / 2
      parent_x = midpoint
      DebugLogger.log("DEBUG: Placing #{person.id} (parent of #{branches.map(&:id).join(',')}) at X=#{parent_x}, Y=#{y}. Next_x was #{current_next_x}")
      if parent_x < current_next_x
        shift_amount = current_next_x - parent_x
        DebugLogger.log("DEBUG: Shifting subtree of #{person.id} by #{shift_amount} to account for Next_x")
        shift_subtree(person, shift_amount, context)
        parent_x = current_next_x
      end
      person.add_coordinate_set(parent_x, y, nil)
      coordinates.add_node(person.id, parent_x, y)
      coordinates.update_next_x(y, parent_x + SIBLING_SPACING)
    end
  end

  def place_couple(spouse1, spouse2, context)
    coordinates = context.coordinates
    y = spouse1.generation * LEVEL_HEIGHT
    branches = context.branches(spouse1)
    coordinates.add_couple(spouse1.id, spouse2.id)
    if branches.empty?
      x1 = coordinates.next_x(y)
      x2 = x1 + COUPLE_SPACING
      spouse1.add_coordinate_set(x1, y, nil)
      spouse2.add_coordinate_set(x2, y, nil)
      coordinates.add_node(spouse1.id, x1, y)
      coordinates.add_node(spouse2.id, x2, y)
      coordinates.update_next_x(y, x2 + SIBLING_SPACING)
    else
      # Center over branches
      branch_xs = branches.map { |b| b.coordinate_set(nil)[0] }
      midpoint = (branch_xs.min + branch_xs.max) / 2
      parent_x1 = midpoint - (COUPLE_SPACING / 2)
      parent_x2 = parent_x1 + COUPLE_SPACING
      if parent_x1 < coordinates.next_x(y)
        shift_amount = coordinates.next_x(y) - parent_x1
        shift_subtree(spouse1, shift_amount, context)
        parent_x1 = coordinates.next_x(y)
        parent_x2 = parent_x1 + COUPLE_SPACING
      end
      spouse1.add_coordinate_set(parent_x1, y, nil)
      spouse2.add_coordinate_set(parent_x2, y, nil)
      coordinates.add_node(spouse1.id, parent_x1, y)
      coordinates.add_node(spouse2.id, parent_x2, y)
      coordinates.update_next_x(y, parent_x2 + SIBLING_SPACING)
    end
  end

  def shift_subtree(person, amount, context)
    coordinates = context.coordinates
    if !person.nil?
      coord = person.coordinate_set(nil)
      if coord
        DebugLogger.log("DEBUG: Shifting node #{person.id} by #{amount}")
        x, y = coord
        new_x = x + amount
        person.add_coordinate_set(new_x, y, nil)
        coordinates.add_node(person.id, new_x, y)
        coordinates.update_next_x(y, [
          coordinates.next_x(y), new_x + SIBLING_SPACING].max)
      end
      if person.has_spouse
        person.spouses.each do |spouse|
          coord = spouse.coordinate_set(nil)
          if coord
            DebugLogger.log("DEBUG: Shifting spouse #{spouse.id} of #{person.id} by #{amount}")
            x, y = coord
            new_x = x + amount
            spouse.add_coordinate_set(new_x, y, nil)
            coordinates.add_node(spouse.id, new_x, y)
            coordinates.update_next_x(y, [
              coordinates.next_x(y), new_x + SIBLING_SPACING].max)
          end
        end
      end
      context.branches(person).each do |branch|
        shift_subtree(branch, amount, context)
      end
    end
  end
end
