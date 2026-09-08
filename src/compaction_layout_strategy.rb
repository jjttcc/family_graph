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
puts "DEBUG: Traversing spouse #{spouse.id} of #{person.id}"
      block.concat(get_connected_block(spouse, graph, visited))
    end
    # Add children and their subtrees
    graph.branches(person).each do |child|
puts "DEBUG: Traversing child #{child.id} of #{person.id}"
      block.concat(get_connected_block(child, graph, visited))
    end
    block.uniq
  end

  # Performs the global compaction pass.
  def compact(graph, people)
    coordinates = graph.coordinates
    # 1. Group nodes by Y-level (generation)
    levels = {}
    coordinates.nodes.each do |id, (x, y)|
      levels[y] ||= []
      levels[y] << id
    end
puts "DEBUG: Levels grouping: #{levels.inspect}"
    # 2. Iterate through levels and compact islands
    levels.each do |y, node_ids|
      # Sort nodes by X coordinate
      sorted_ids = node_ids.sort_by { |id| coordinates.node(id)[0] }
      # 3. Find gaps and shift
      threshold = SIBLING_SPACING * 2
      sorted_ids.each_with_index do |id1, i|
        next if i == sorted_ids.size - 1
        id2 = sorted_ids[i+1]
        x1 = coordinates.node(id1)[0]
        x2 = coordinates.node(id2)[0]
        gap = x2 - (x1 + SIBLING_SPACING) 
        if gap > threshold then
          shift_amount = -(gap - SIBLING_SPACING)
          p = people[id2]
puts "DEBUG: Gap detected at Y=#{y}: #{gap} between #{id1} (X=#{x1}) and #{id2} (X=#{x2})"
puts "DEBUG: Shifting #{p.id}'s subtree (Spouses: #{p.spouses.map(&:id).join(', ')}) by #{shift_amount}"
          # Shift the entire connected block of person2
          block = get_connected_block(p, graph)
          block.each do |node|
            if graph.coordinates.has_node?(node.id)
              x, curr_y = graph.coordinates.node(node.id)
              graph.coordinates.add_node(node.id, x + shift_amount, curr_y)
            else
puts "DEBUG: WARNING: Node #{node.id} not found in coordinates during shift!"
            end
          end
        end
      end
    end
  end

end
