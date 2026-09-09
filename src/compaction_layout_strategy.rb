require_relative 'layout_strategy'
require_relative 'family_constants'

# Identifies disconnected node islands at the same generation level
# and compacts them horizontally to minimize wasted space.
class CompactionLayoutStrategy < LayoutStrategy
  include Contracts::DSL

  def add_individual(person, graph)
    # Compaction is a post-process pass, so it does nothing here
  end

  def add_couple(spouse1, spouse2, graph)
    # Compaction is a post-process pass, so it does nothing here
  end

  # Shifts coordinate of a subtree based on compaction logic.
  def shift_subtree(person, amount, graph)
    # Compaction is a post-process pass that needs to be triggered after 
    # initial placement.
  end

  # Identify all nodes connected to a person (spouses, children, descendants)
  def get_connected_block(person, graph, visited = [])
    return [] if visited.include?(person.id)
    visited << person.id
    block = [person]
    # Add spouses and their subtrees
    person.spouses.each do |spouse|
      block.concat(get_connected_block(spouse, graph, visited))
    end
    # Add children and their subtrees
    graph.branches(person).each do |child|
      block.concat(get_connected_block(child, graph, visited))
    end
    block.uniq
  end

  # Performs the global compaction pass until no collisions or gaps exist.
  def compact(graph, people)
    coordinates = graph.coordinates
    levels = {}
    coordinates.nodes.each do |id, (x, y)|
      levels[y] ||= []
      levels[y] << id
    end

    # Keep compacting until a full pass completes with no shifts or we hit safety limit
    max_passes = 20
    pass_count = 0
    
    loop do
      pass_count += 1
      if pass_count > max_passes
        puts "WARNING: Compaction reached safety limit of #{max_passes} passes. Breaking to prevent infinite loop."
        break
      end

      shifted = false
      levels.each do |y, node_ids|
        sorted_ids = node_ids.sort_by { |id| coordinates.node(id)[0] }
        threshold = SIBLING_SPACING * 2

        sorted_ids.each_with_index do |id1, i|
          next if i == sorted_ids.size - 1
          id2 = sorted_ids[i+1]
          x1 = coordinates.node(id1)[0]
          x2 = coordinates.node(id2)[0]

          # Ensure minimum separation
          min_separation = NODE_WIDTH + 20

          # 1. Check for Overlaps (Too Close)
          if (x2 - x1) < min_separation
            shift_amount = min_separation - (x2 - x1)
            puts "DEBUG: Overlap detected at Y=#{y}: #{id1} and #{id2}. Shifting #{id2} by #{shift_amount} (Pass #{pass_count})"
            p2 = people[id2]
            block = get_connected_block(p2, graph)
            block.each do |node|
              if graph.coordinates.has_node?(node.id)
                x, curr_y = graph.coordinates.node(node.id)
                graph.coordinates.add_node(node.id, x + shift_amount, curr_y)
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
            block = get_connected_block(p, graph)
            block.each do |node|
              if graph.coordinates.has_node?(node.id)
                x, curr_y = graph.coordinates.node(node.id)
                graph.coordinates.add_node(node.id, x + shift_amount, curr_y)
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

end
