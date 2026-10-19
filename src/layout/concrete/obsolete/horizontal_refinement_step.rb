# frozen_string_literal: true

require 'assertions'
require 'layout_step'
require 'family_constants'

# Refines horizontal positioning after hierarchical placement, shifting
# isolated or zero-offspring dangling nodes/couples to the left margin.
class HorizontalRefinementStep < LayoutStep
  include Contracts::DSL, Assertions, DebugLogger

  public

  def execute
    coords = context.coordinates
    # Group nodes by y level
    levels = Hash.new { |h, k| h[k] = [] }
    coords.single_nodes.each do |id, node|
      levels[node.y] << [:person, node]
    end
    coords.couples.each do |id, couple_node|
      levels[couple_node.y] << [:couple, couple_node]
    end
    levels.each do |y, nodes_on_level|
      # Identify isolated or zero-offspring dangling nodes/couples
      isolated = nodes_on_level.select do |type, node|
        if type == :person
          person = node.person
#          check { person.parents.empty? && person.children.empty? &&
#                  !person.has_spouse }
        else
          check { node.is_a?(CoupleNode) }
          p_a = couple_node_partner_a(node)
          p_b = couple_node_partner_b(node)
puts p_a.class
puts p_b.class
#          p_a = node.person_a
#          p_b = node.person_b
          # Check children specific to this couple partnership
          children = []
          if p_a
            children = context.branches(p_a).select do |child|
              child.parents.include?(p_a) || (p_b && child.parents.include?(p_b))
            end
          end
          # A couple is dangling/isolated if they have zero children together
          children.empty?
        end
      end
      # If there are isolated/dangling nodes, shift them to the far left margin
      if !isolated.empty?
        # Find min x of connected nodes on this level
        connected = nodes_on_level - isolated
        min_connected_x = connected.map { |_, n| n.x }.min
        target_x = min_connected_x ? [50, min_connected_x - 200].min : 50
        isolated.each do |type, node|
          if type == :person
            node.x = target_x
          else
            dx = target_x - node.x
            node.shift!(dx)
          end
        end
      end
    end
  end

  private

  def couple_node_partner_a(couple_node)
    couple_node.respond_to?(:partner_a) ? couple_node.partner_a&.person : nil
  end

  def couple_node_partner_b(couple_node)
    couple_node.respond_to?(:partner_b) ? couple_node.partner_b&.person : nil
  end

end
