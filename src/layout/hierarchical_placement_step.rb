require 'layout_step'
require 'graph_primitives'
require 'set'

# Implements recursive, top-down generation-order hierarchical placement
# utilizing pre-calculated offspring widths for centering.
class HierarchicalPlacementStep < LayoutStep
  include Contracts::DSL

  public  ###  Layout Execution

  # Executes the hierarchical placement step by placing all root persons
  # and recursively positioning their descendants top-down.
  pre 'valid_context' do |context| context.is_a?(LayoutContext) end
  def execute(context)
    @coords = context.coordinates
    processed_couples = Set.new
    context.roots.each do |root|
      place_person(root, context, root.generation * LEVEL_HEIGHT,
                   processed_couples)
    end
  end

  private  ###  Placement Helpers

  attr_reader :coords

  # Places an individual person or their couple representation based on
  # marital status.
  def place_person(person, context, y, processed_couples)
    if person.has_spouse then
      place_couple(person, context, y, processed_couples)
    else
      place_individual(person, context, y, processed_couples)
    end
  end

  # Places an individual singleton person node and positions their children.
  def place_individual(person, context, y, processed_couples)
    node = coords.node_for_person(person)
    if node then
      if node.x == 0 && node.y == 0 then
        node.y = y
        node.x = coords.next_x(y)
        coords.update_next_x(y, node.x + NODE_WIDTH + SIBLING_SPACING)
      end
      place_children(person, context, y + LEVEL_HEIGHT, node,
                     NODE_WIDTH, processed_couples)
    end
  end

  # Places a couple node and positions their children.
  def place_couple(person, context, y, processed_couples)
    person.spouses.each do |spouse|
      couple_id = [person.id, spouse.id].sort
      if !processed_couples.include?(couple_id) then
        couple_node = coords.node_for_couple(person, spouse)
        if couple_node then
          if couple_node.x == 0 && couple_node.y == 0 then
            couple_node.y = y
            couple_width = (2 * NODE_WIDTH) + COUPLE_SPACING
            couple_node.x = coords.next_x(y)
            couple_node.partner_a.x = couple_node.x
            couple_node.partner_a.y = y
            couple_node.partner_b.x = couple_node.x + NODE_WIDTH + 20
            couple_node.partner_b.y = y
            coords.update_next_x(y, couple_node.x + couple_width +
                                 SIBLING_SPACING)
          end
          processed_couples.add(couple_id)
          place_couple_children(person, spouse, context, y + LEVEL_HEIGHT,
                                couple_node, (2 * NODE_WIDTH) + COUPLE_SPACING,
                                processed_couples)
        end
      end
    end
  end

  # Identifies and lays out children for an individual person.
  def place_children(person, context, y, parent_node, parent_width,
                     processed_couples)
    children = context.branches(person).select do |child|
      !person.has_spouse || child.parents.include?(person)
    end
    if !children.empty? then
      layout_children_group(children, context, y, parent_node,
                            parent_width, processed_couples)
    end
  end

  # Identifies and lays out children for a couple.
  def place_couple_children(person_a, person_b, context, y, couple_node,
                            couple_width, processed_couples)
    children = context.branches(person_a).select do |child|
      child.parents.include?(person_a) || child.parents.include?(person_b)
    end
    if !children.empty? then
      layout_children_group(children, context, y, couple_node,
                            couple_width, processed_couples)
    end
  end

  # Lays out a group of children centered beneath their parent node.
  def layout_children_group(children, context, y, parent_node, parent_width,
                            processed_couples)
    offspring_width = parent_node.offspring_width || 0
    parent_center = if parent_node.is_a?(CoupleNode) then
      (parent_node.partner_a.x + parent_node.partner_b.x) / 2.0
    else
      parent_node.x + (parent_width / 2.0)
    end
    start_x = parent_center - (offspring_width / 2.0)

    current_x = start_x
    children.each do |child|
      if child.has_spouse then
        child.spouses.each do |spouse|
          couple_id = [child.id, spouse.id].sort
          if !processed_couples.include?(couple_id) then
            couple_node = coords.node_for_couple(child, spouse)
            if couple_node then
              couple_width = (2 * NODE_WIDTH) + COUPLE_SPACING
              if couple_node.x == 0 && couple_node.y == 0 then
                couple_node.y = y
                couple_node.x = current_x
                couple_node.partner_a.x = current_x
                couple_node.partner_a.y = y
                couple_node.partner_b.x = current_x + NODE_WIDTH + 20
                couple_node.partner_b.y = y
                coords.update_next_x(y, current_x + couple_width +
                                     SIBLING_SPACING)
              end
              processed_couples.add(couple_id)
              place_couple_children(child, spouse, context, y + LEVEL_HEIGHT,
                                    couple_node, couple_width,
                                    processed_couples)
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
          place_children(child, context, y + LEVEL_HEIGHT, child_node,
                         NODE_WIDTH, processed_couples)
          current_x += NODE_WIDTH + SIBLING_SPACING
        end
      end
    end
  end
end
