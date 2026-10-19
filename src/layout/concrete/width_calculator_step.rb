# vim: ts=2 sw=2 expandtab
require 'layout_step'
require 'family_constants'

# Calculates the required horizontal width for each node's offspring-generation
# using node-centric child node queries.
class WidthCalculatorStep < LayoutStep
  include Contracts::DSL

  public

  # Executes the width calculator step, populating offspring_width
  # for all single and couple nodes.
  def execute
    coords = context.coordinates
    coords.single_nodes.each_value do |node|
      node.offspring_width = node_offspring_width(node, coords)
    end
    coords.couples.each_value do |couple_node|
      width = couple_offspring_width(couple_node, coords)
      couple_node.offspring_width = width
      couple_node.partner_a.offspring_width = width
      couple_node.partner_b.offspring_width = width
    end
    coords.set_nodes_initialized
  end

  private ### Implementation

  # Offspring width for a singleton person node.
  def node_offspring_width(node, coords)
    child_nodes = coords.child_nodes_for(node)
    nodes_width(child_nodes)
  end

  # Offspring width for a couple node.
  def couple_offspring_width(couple_node, coords)
    child_nodes = coords.child_nodes_for(couple_node)
    nodes_width(child_nodes)
  end

  # Total width required for a list of nodes.
  def nodes_width(nodes)
    result = 0
    if ! nodes.empty? then
      total_w = nodes.sum { |cn| cn.width }
      spacing_w = (nodes.size - 1) * SIBLING_SPACING
      result = total_w + spacing_w
    end
    result
  end

end
