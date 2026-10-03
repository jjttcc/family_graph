# vim: ts=2 sw=2 expandtab
require 'layout_step'
require 'ruby_contracts'
require 'family_constants'

# Implements Stage 3 bounding-box overlap elimination, detecting and resolving
# horizontal node collisions across layout levels.
class OverlapEliminationStep < LayoutStep
  include Contracts::DSL

  public

  # Executes bounding-box overlap elimination on coordinates registry
  # and records overlap detection metrics.
  def execute
    coords = context.coordinates
    levels = nodes_by_level(coords)
    initial_count = overlaps(coords, levels)
    coords.initial_overlap_count = initial_count
    eliminate_overlaps(coords, levels)
    final_levels = nodes_by_level(coords)
    final_count = overlaps(coords, final_levels)
    coords.remaining_overlap_count = final_count
  end

  private

  # Total number of overlaps in 'coords'
  def overlaps(coords, levels)
    result = 0
    levels.each do |_y, nodes|
      sorted_nodes = nodes.sort_by(&:x)
      sorted_nodes.each_with_index do |node1, i|
        if i != sorted_nodes.size - 1 then
          node2 = sorted_nodes[i + 1]
          width1 = node1.width
          min_separation = width1 + 20
          actual_separation = node2.x - node1.x
          if actual_separation < min_separation then
            result += 1
          end
        end
      end
    end
    result
  end

  # Detects and resolves overlapping bounding boxes on each Y level.
  def eliminate_overlaps(coords, levels)
    max_passes = 15
    pass_count = 0
    loop do
      pass_count += 1
      if pass_count > max_passes then
        break
      end
      shifted = false
      levels.each do |_y, nodes|
        sorted_nodes = nodes.sort_by(&:x)
        sorted_nodes.each_with_index do |node1, i|
          if i != sorted_nodes.size - 1 then
            node2 = sorted_nodes[i + 1]
            width1 = node1.width
            min_separation = width1 + 20
            actual_separation = node2.x - node1.x
            if actual_separation < min_separation then
              shift_amount = min_separation - actual_separation
              node2.x += shift_amount
              shifted = true
            end
          end
        end
      end
      if !shifted then
        break
      end
    end
  end

  # Collects all nodes (single nodes and couples) grouped by their Y coordinate.
  def nodes_by_level(coords)
    result = {}
    coords.single_nodes.values.each do |node|
      y = node.y
      result[y] ||= []
      result[y] << node
    end
    coords.couples.values.each do |couple|
      y = couple.y
      result[y] ||= []
      result[y] << couple
    end
    result
  end

  # !!! obsolete: remove
  def node_width(node)
    if node.respond_to?(:partner_a) then
      COUPLE_WIDTH
    else
      NODE_WIDTH
    end
  end

end
