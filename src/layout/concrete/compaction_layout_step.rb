# vim: ts=2 sw=2 expandtab
require 'debug_logger'
require 'layout_step'
require 'family_constants'

class CompactionLayoutStep < LayoutStep
  include Contracts::DSL

  public

  def execute
    people = context.people
    compact(people)
  end

  private

  def compact(people)
    coords = context.coordinates
    levels = {}
    coords.single_nodes.each do |id, node|
      y = node.y
      levels[y] ||= []
      levels[y] << id
    end
    max_passes = 20
    pass_count = 0
    loop do
      pass_count += 1
      break if pass_count > max_passes
      shifted = false
      levels.each do |y, node_ids|
        sorted_ids = node_ids.sort_by { |id| coords.node_by_person_id(id).x }
        threshold = SIBLING_SPACING * 2
        sorted_ids.each_with_index do |id1, i|
          next if i == sorted_ids.size - 1
          id2 = sorted_ids[i + 1]
          node1 = coords.node_by_person_id(id1)
          node2 = coords.node_by_person_id(id2)
          min_separation = NODE_WIDTH + 20
          if (node2.x - node1.x) < min_separation then
            shift_amount = min_separation - (node2.x - node1.x)
            block = connected_block(id2)
            block.each { |id| coords.node_by_person_id(id).x += shift_amount }
            shifted = true
            break
          end
          gap = node2.x - (node1.x + SIBLING_SPACING)
          if gap > threshold then
            shift_amount = -(gap - SIBLING_SPACING)
            block = connected_block(id2)
            block.each { |id| coords.node_by_person_id(id).x += shift_amount }
            shifted = true
            break
          end
        end
      end
      break if !shifted
    end
  end

  def connected_block(person_id, visited = Set.new)
    return [] if visited.include?(person_id)
    visited << person_id
    block = [person_id]
    person = context.people[person_id]
    person.spouses.each do |spouse|
      block.concat(connected_block(spouse.id, visited))
    end
    context.branches(person).each do |child|
      block.concat(connected_block(child.id, visited))
    end
    block.uniq
  end

end
