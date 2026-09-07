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

  # Performs the global compaction pass.
  def compact(graph, people)
    coordinates = graph.coordinates
    
    # 1. Group nodes by Y-level (generation)
    levels = {}
    coordinates.nodes.each do |id, (x, y)|
      levels[y] ||= []
      levels[y] << id
    end

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
          # Shift the entire subtree of id2 to the left
          shift_amount = -(gap - SIBLING_SPACING)
          graph.shift_subtree(people[id2], shift_amount)
        end
      end
    end
  end
end
