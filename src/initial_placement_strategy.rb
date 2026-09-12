require_relative 'debug_logger'
require_relative 'layout_strategy'
require_relative 'family_constants'

# Implements the recursive placement strategy, maintaining the original
# logic for node and spousal coordinate calculation.
class InitialPlacementStrategy < LayoutStrategy
  include Contracts::DSL

  def apply(graph)
    # The graph holds the roots
    graph.instance_variable_get(:@roots).each do |root|
      traverse_and_place(root, graph)
    end
  end

  private

  def traverse_and_place(person, graph)
    # Recursively traverse branches first
    graph.branches(person).each { |child| traverse_and_place(child, graph) }

    if person.has_spouse
      place_couple(person, person.spouse, graph)
    else
      place_individual(person, graph)
    end
  end

  def place_individual(person, graph)
    y = person.generation * LEVEL_HEIGHT
    branches = graph.branches(person)
    current_next_x = graph.coordinates.next_x(y)
    
    if branches.empty?
      x = current_next_x
      DebugLogger.log("DEBUG: Placing #{person.id} (OID: #{person.object_id}) at X=#{x}, Y=#{y}. Next_x was #{current_next_x}")
      person.add_coordinate_set(x, y, nil)
      graph.coordinates.add_node(person.id, x, y)
      graph.coordinates.update_next_x(y, x + SIBLING_SPACING)
    else
      # Center over branches
      branch_xs = branches.map { |br| br.coordinate_set(nil)[0] }
      midpoint = (branch_xs.min + branch_xs.max) / 2
      parent_x = midpoint
      DebugLogger.log("DEBUG: Placing #{person.id} (parent of #{branches.map(&:id).join(',')}) at X=#{parent_x}, Y=#{y}. Next_x was #{current_next_x}")
      if parent_x < current_next_x
        shift_amount = current_next_x - parent_x
        DebugLogger.log("DEBUG: Shifting subtree of #{person.id} by #{shift_amount} to account for Next_x")
        shift_subtree(person, shift_amount, graph)
        parent_x = current_next_x
      end
      person.add_coordinate_set(parent_x, y, nil)
      graph.coordinates.add_node(person.id, parent_x, y)
      graph.coordinates.update_next_x(y, parent_x + SIBLING_SPACING)
    end
  end

  def place_couple(spouse1, spouse2, graph)
    y = spouse1.generation * LEVEL_HEIGHT
    branches = graph.branches(spouse1)
    graph.coordinates.add_couple(spouse1.id, spouse2.id)
    if branches.empty?
      x1 = graph.coordinates.next_x(y)
      x2 = x1 + COUPLE_SPACING
      spouse1.add_coordinate_set(x1, y, nil)
      spouse2.add_coordinate_set(x2, y, nil)
      graph.coordinates.add_node(spouse1.id, x1, y)
      graph.coordinates.add_node(spouse2.id, x2, y)
      graph.coordinates.update_next_x(y, x2 + SIBLING_SPACING)
    else
      # Center over branches
      branch_xs = branches.map { |b| b.coordinate_set(nil)[0] }
      midpoint = (branch_xs.min + branch_xs.max) / 2
      parent_x1 = midpoint - (COUPLE_SPACING / 2)
      parent_x2 = parent_x1 + COUPLE_SPACING
      if parent_x1 < graph.coordinates.next_x(y)
        shift_amount = graph.coordinates.next_x(y) - parent_x1
        shift_subtree(spouse1, shift_amount, graph)
        parent_x1 = graph.coordinates.next_x(y)
        parent_x2 = parent_x1 + COUPLE_SPACING
      end
      spouse1.add_coordinate_set(parent_x1, y, nil)
      spouse2.add_coordinate_set(parent_x2, y, nil)
      graph.coordinates.add_node(spouse1.id, parent_x1, y)
      graph.coordinates.add_node(spouse2.id, parent_x2, y)
      graph.coordinates.update_next_x(y, parent_x2 + SIBLING_SPACING)
    end
  end

  def shift_subtree(person, amount, graph)
    if !person.nil?
      coord = person.coordinate_set(nil)
      if coord
        DebugLogger.log("DEBUG: Shifting node #{person.id} by #{amount}")
        x, y = coord
        new_x = x + amount
        person.add_coordinate_set(new_x, y, nil)
        graph.coordinates.add_node(person.id, new_x, y)
        graph.coordinates.update_next_x(y, [
          graph.coordinates.next_x(y), new_x + SIBLING_SPACING].max)
      end
      if person.has_spouse
        person.spouses.each do |spouse|
          coord = spouse.coordinate_set(nil)
          if coord
            DebugLogger.log("DEBUG: Shifting spouse #{spouse.id} of #{person.id} by #{amount}")
            x, y = coord
            new_x = x + amount
            spouse.add_coordinate_set(new_x, y, nil)
            graph.coordinates.add_node(spouse.id, new_x, y)
            graph.coordinates.update_next_x(y, [
              graph.coordinates.next_x(y), new_x + SIBLING_SPACING].max)
          end
        end
      end
      graph.branches(person).each do |branch|
        shift_subtree(branch, amount, graph)
      end
    end
  end
end
