# vim: ts=2 sw=2 expandtab
require 'debug_logger'
require 'layout_step'
require 'family_constants'
# Identifies disconnected node islands at the same generation level
# and compacts them horizontally to minimize wasted space.
class CompactionLayoutStep < LayoutStep
  include Contracts::DSL

  public

  # Performs the global compaction pass until no collisions or gaps exist.
  def execute(context)
    people = context.people
    compact(context, people)
  end

  def compact(context, people)
    levels = {}
    people.each_value do |person|
      coord = person.self_coordinates
      if coord then
        y = coord[1]
        levels[y] ||= []
        levels[y] << person.id
      end
    end
    max_passes = 20
    pass_count = 0
    loop do
      pass_count += 1
      if pass_count > max_passes then
        DebugLogger.log(["WARNING: Compaction reached safety limit",
          "of #{max_passes} passes. Breaking."], "\n")
        break
      end
      shifted = false
      levels.each do |y, node_ids|
        sorted_ids = node_ids.sort_by do |id|
          people[id].self_coordinates[0]
        end
        threshold = SIBLING_SPACING * 2
        sorted_ids.each_with_index do |id1, i|
          if i == sorted_ids.size - 1 then
            next
          end
          id2 = sorted_ids[i + 1]
          x1 = people[id1].self_coordinates[0]
          x2 = people[id2].self_coordinates[0]
          min_separation = NODE_WIDTH + 20
          if (x2 - x1) < min_separation then
            shift_amount = min_separation - (x2 - x1)
            DebugLogger.log(["DEBUG: Overlap detected at Y=#{y}:",
              "#{id1} and #{id2}. Shifting #{id2} by #{shift_amount}",
              "(Pass #{pass_count})"], "\n")
            p2 = people[id2]
            block = connected_block(p2, context)
            block.each do |node|
              coord = node.self_coordinates
              if coord then
                context.update_person(node, coord[0] + shift_amount,
                  coord[1], nil)
              end
            end
            shifted = true
            break
          end
          gap = x2 - (x1 + SIBLING_SPACING)
          if gap > threshold then
            shift_amount = -(gap - SIBLING_SPACING)
            p = people[id2]
            block = connected_block(p, context)
            block.each do |node|
              coord = node.self_coordinates
              if coord then
                context.update_person(node, coord[0] + shift_amount,
                  coord[1], nil)
              end
            end
            shifted = true
            break
          end
        end
      end
      if !shifted then
        break
      end
    end
  end

  private

  # All nodes connected to a person (spouses, children, descendants)
  def connected_block(person, context, visited = [])
    if visited.include?(person.id) then
      return []
    end
    visited << person.id
    block = [person]
    person.spouses.each do |spouse|
      block.concat(connected_block(spouse, context, visited))
    end
    context.branches(person).each do |child|
      block.concat(connected_block(child, context, visited))
    end
    block.uniq
  end

end
