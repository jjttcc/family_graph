# vim: ts=2 sw=2 expandtab
require 'set'
require 'family_constants'
require 'layout_step'
require 'graph_primitives'

# Implements recursive, top-down generation-order hierarchical placement
# utilizing pre-calculated offspring widths for centering.
class HierarchicalPlacementStep < LayoutStep
  include Contracts::DSL, DebugLogger

  public

  # Place all root nodes and recursively position their descendants top-down.
  def execute
    @coords = context.coordinates
    @processed_nodes = Set.new
    coords.root_nodes.each do |root_node|
      place_node(root_node, root_node.generation * LEVEL_HEIGHT)
    end
  end

  private ###  Implementation

  attr_reader :coords, :processed_nodes

  # Place a node (PersonNode or CoupleNode) and position its descendants.
  def place_node(node, y)
    if !processed_nodes.include?(node.id) then
      processed_nodes.add(node.id)
      if node.x == 0 && node.y == 0 then
        node.initialize_coordinates(coords.next_x(y), y)
        coords.update_next_x(y, node.x + node.width + SIBLING_SPACING)
      end
      child_nodes = coords.child_nodes_for(node)
      if !child_nodes.empty? then
        layout_siblings(child_nodes, y + LEVEL_HEIGHT, node)
      end
    end
  end

  # Lay out a group of child nodes centered beneath their parent node.
  def layout_siblings(children, y, parent_node)
    offspring_width = parent_node.offspring_width
    parent_center = parent_node.center_x
    start_x = parent_center - (offspring_width / 2.0)
    current_x = start_x
    children.each do |child_node|
      if !processed_nodes.include?(child_node.id) then
        processed_nodes.add(child_node.id)
        if child_node.x == 0 && child_node.y == 0 then
          child_node.initialize_coordinates(current_x, y)
          coords.update_next_x(y, current_x + child_node.width +
                               SIBLING_SPACING)
        end
        grand_children = coords.child_nodes_for(child_node)
        if !grand_children.empty? then
          layout_siblings(grand_children, y + LEVEL_HEIGHT, child_node)
        end
        current_x += child_node.width + SIBLING_SPACING
      end
    end
  end

end
