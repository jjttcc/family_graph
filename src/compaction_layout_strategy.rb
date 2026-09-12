require_relative 'debug_logger'
require_relative 'layout_strategy'
require_relative 'family_constants'

# Identifies disconnected node islands at the same generation level
# and compacts them horizontally to minimize wasted space.
class CompactionLayoutStrategy < LayoutStrategy
  include Contracts::DSL
# Performs the global compaction pass until no collisions or gaps exist.
def apply(graph)
  people = graph.instance_variable_get(:@people)
  compact(graph, people)
end

def compact(graph, people)
  # ... rest of the method

    # Extract nodes from people instead of global coordinates hash
    levels = {}
    people.each do |id, person|
      coord = person.coordinate_set(nil)
      if coord
        y = coord[1]
        levels[y] ||= []
        levels[y] << id
      end
    end
    # Keep compacting until a full pass completes with no shifts or we hit
    # safety limit
    max_passes = 20
    pass_count = 0
    loop do
      pass_count += 1
      if pass_count > max_passes
        DebugLogger.log("WARNING: Compaction reached safety limit of " +
            "#{max_passes} passes. Breaking to prevent infinite loop.")
        break
      end
      shifted = false
      levels.each do |y, node_ids|
        sorted_ids = node_ids.sort_by { |id| people[id].coordinate_set(nil)[0] }
        threshold = SIBLING_SPACING * 2
        sorted_ids.each_with_index do |id1, i|
          next if i == sorted_ids.size - 1
          id2 = sorted_ids[i+1]
          x1 = people[id1].coordinate_set(nil)[0]
          x2 = people[id2].coordinate_set(nil)[0]
          # Ensure minimum separation
          min_separation = NODE_WIDTH + 20
          # 1. Check for Overlaps (Too Close)
          if (x2 - x1) < min_separation
            shift_amount = min_separation - (x2 - x1)
            DebugLogger.log("DEBUG: Overlap detected at Y=#{y}: #{id1} " +
              "and #{id2}. Shifting #{id2} by #{shift_amount} " +
              "(Pass #{pass_count})")
            p2 = people[id2]
            block = connected_block(p2, graph)
            block.each do |node|
              coord = node.coordinate_set(nil)
              if coord
                node.add_coordinate_set(coord[0] + shift_amount, coord[1], nil)
              end
            end
            shifted = true
            break
          end
          # 2. Check for Excessive Gaps (Too Far)
          gap = x2 - (x1 + SIBLING_SPACING)
          if gap > threshold then
            shift_amount = -(gap - SIBLING_SPACING)
            p = people[id2]
            block = connected_block(p, graph)
            block.each do |node|
              coord = node.coordinate_set(nil)
              if coord
                node.add_coordinate_set(coord[0] + shift_amount, coord[1], nil)
              end
            end
            shifted = true
            break
          end
        end
      end
      break unless shifted
    end
  end

  private

  # All nodes connected to a person (spouses, children, descendants)
  def connected_block(person, graph, visited = [])
    return [] if visited.include?(person.id)
    visited << person.id
    block = [person]
    # Add spouses and their subtrees
    person.spouses.each do |spouse|
      block.concat(connected_block(spouse, graph, visited))
    end
    # Add children and their subtrees
    graph.branches(person).each do |child|
      block.concat(connected_block(child, graph, visited))
    end
    block.uniq
  end

end
