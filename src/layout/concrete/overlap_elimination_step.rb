# vim: ts=2 sw=2 expandtab
require 'debug_logger'
require 'layout_step'
require 'ruby_contracts'
require 'family_constants'
require 'assertions'

# Implements Stage 3 bounding-box overlap elimination across all layout units
# (single person nodes and couple nodes) using 2D AABB collision detection
# with couple-atomic unit shifting.
class OverlapEliminationStep < LayoutStep
  include Contracts::DSL, Assertions, DebugLogger

  public

  # Executes bounding-box overlap elimination on coordinates registry
  # and records overlap detection metrics.
  def execute
    coords = context.coordinates
    nodes = all_layout_nodes(coords)
    initial_pairs = overlaps(nodes)
    coords.initial_overlap_count = initial_pairs.size
    log("OverlapEliminationStep: Initial overlaps detected: ",
        "#{initial_pairs.size}")
    max_passes = 1_000_000
    pass = 0
    loop do
      pass += 1
      current_pairs = overlaps(nodes)
      log("OverlapEliminationStep: Pass #{pass}: ",
          "found #{current_pairs.size} overlap(s)")
      if current_pairs.empty? || pass > max_passes then
        break
      end
      resolve_overlaps(current_pairs)
    end
    final_pairs = overlaps(nodes)
    coords.remaining_overlap_count = final_pairs.size
    log("OverlapEliminationStep: Final remaining overlaps: ",
        "#{final_pairs.size}")
    check("All overlaps must be eliminated") { final_pairs.empty? }
  end

  private

  # Collects all layout units (single nodes + couple nodes)
  def all_layout_nodes(coords)
    coords.single_nodes.values + coords.couples.values
  end

  # Identifies and returns an array of overlapping layout node pairs
  # [node1, node2]
  def overlaps(nodes)
    overlap_pairs = []
    sorted_nodes = nodes.sort_by { |n| [n.y, n.x] }
    sorted_nodes.each_with_index do |node1, i|
      ((i + 1)...sorted_nodes.size).each do |j|
        node2 = sorted_nodes[j]
        if node1.y == node2.y && bounding_boxes_overlap(node1, node2) then
          overlap_pairs << [node1, node2]
        else
          break if node2.y > node1.y || node2.x >= node1.x + node1.width + 20
        end
      end
    end
    overlap_pairs
  end

  # Resolves a given list of overlapping node pairs by atomically shifting node2
  # rightwards
  def resolve_overlaps(overlap_pairs)
    overlap_pairs.each do |node1, node2|
      required_x = node1.x + node1.width + 20
      if node2.x < required_x then
        shift_amount = required_x - node2.x
        node2.shift!(shift_amount)
      end
    end
  end

  # Robust 2D Axis-Aligned Bounding Box (AABB) overlap check including
  # 20px minimum separation, using polymorphic node widths
  def bounding_boxes_overlap(node1, node2)
    x1 = node1.x
    y1 = node1.y
    w1 = node1.width
    h1 = NODE_HEIGHT
    x2 = node2.x
    y2 = node2.y
    w2 = node2.width
    h2 = NODE_HEIGHT
    # Two nodes overlap if their bounding boxes
    # (with 20px min separation) intersect
    !(x1 >= x2 + w2 + 20 || x1 + w1 + 20 <= x2 || y1 >= y2 + h2 ||
      y1 + h1 <= y2)
  end

end
