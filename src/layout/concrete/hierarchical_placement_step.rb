require 'set'
require 'family_constants'
require 'layout_step'
require 'graph_primitives'

# Implements recursive, top-down generation-order hierarchical placement
# utilizing pre-calculated offspring widths for centering.
class HierarchicalPlacementStep < LayoutStep
  include Contracts::DSL, DebugLogger

  public

  # Place all root persons and recursively position their descendants top-down.
  def execute
    @coords = context.coordinates
    @processed_couples = Set.new
    context.roots.each do |root|
      place_person(root, root.generation * LEVEL_HEIGHT)
    end
  end

  private ###  Implementation

  attr_reader :coords, :processed_couples

  # Place an individual person or its couple representation based on
  # marital status.
  def place_person(person, y)
    if person.has_spouse then
      place_couple(person, y)
    else
      place_individual(person, y)
    end
  end

  # Place an individual singleton person node and position its descendants,
  # recursively.
  def place_individual(person, y)
    node = coords.node_for_person(person)
    if node then
      if node.x == 0 && node.y == 0 then
        node.y = y
        node.x = coords.next_x(y)
        coords.update_next_x(y, node.x + NODE_WIDTH + SIBLING_SPACING)
      end
      place_children(person, y + LEVEL_HEIGHT, node)
    end
  end

  # Place a couple node and position its descendants, recursively.
  def place_couple(person, y)
    person.spouses.each do |spouse|
      couple_id = [person.id, spouse.id].sort
      if !processed_couples.include?(couple_id) then
        couple_node = coords.node_for_couple(person, spouse)
        if couple_node then
          if couple_node.x == 0 && couple_node.y == 0 then
            couple_width = COUPLE_WIDTH
            couple_node.initialize_coordinates(coords.next_x(y), y)
            coords.update_next_x(y, couple_node.x + couple_width +
                                 SIBLING_SPACING)
          end
          processed_couples.add(couple_id)
          place_couple_children(person, spouse, y + LEVEL_HEIGHT,
                                couple_node)
        end
      end
    end
  end

  # Identify and lay out descendants for an individual person.
  def place_children(person, y, parent_node)
    children = context.branches(person).select do |child|
      !person.has_spouse || child.parents.include?(person)
    end
    if !children.empty? then
      layout_siblings(children, y, parent_node)
    end
  end

  # Identify and lay out descendants for a couple.
  def place_couple_children(person_a, person_b, y, couple_node)
    children = context.branches(person_a).select do |child|
      child.parents.include?(person_a) || child.parents.include?(person_b)
    end
    if !children.empty? then
      layout_siblings(children, y, couple_node)
    end
  end

  # Lay out a group of siblings centered beneath their parent node.
  def layout_siblings(children, y, parent_node)
    offspring_width = parent_node.offspring_width
    parent_center = parent_node.center_x
    start_x = parent_center - (offspring_width / 2.0)
    current_x = start_x
    children.each do |child|
      if child.has_spouse then
        child.spouses.each do |spouse|
          couple_id = [child.id, spouse.id].sort
          if !processed_couples.include?(couple_id) then
            couple_node = coords.node_for_couple(child, spouse)
            if couple_node then
              couple_width = COUPLE_WIDTH
              if couple_node.x == 0 && couple_node.y == 0 then
                couple_node.initialize_coordinates(current_x, y)
                coords.update_next_x(y, current_x + couple_width +
                                     SIBLING_SPACING)
              end
              processed_couples.add(couple_id)
              place_couple_children(child, spouse, y + LEVEL_HEIGHT,
                                    couple_node)
              current_x += couple_width + SIBLING_SPACING
            end
          end
        end
      else
        child_node = coords.node_for_person(child)
        if child_node then
          if child_node.x == 0 && child_node.y == 0 then
            child_node.y = y
            child_node.x = current_x
            coords.update_next_x(y, current_x + NODE_WIDTH + SIBLING_SPACING)
          end
          place_children(child, y + LEVEL_HEIGHT, child_node)
          current_x += NODE_WIDTH + SIBLING_SPACING
        end
      end
    end
  end

end
