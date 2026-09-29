# vim: ts=2 sw=2 expandtab
require 'ruby_contracts'
require 'family_constants'

# Objects that perform analysis of parent-child connection lines in the
# coordinate layout to detect and report intersecting line segments
class LineCrossingAnalysis
  include Contracts::DSL

  public ###  Analysis Queries

  # Analyzes the given coordinate registry and returns an array of crossing
  # line pairs.
  # The result of analysis of the given coordinate registry:
  #   Array of "line pairs"
  # Each pair is represented as [[parent1, child1], [parent2, child2]].
  def crossing_pairs(coordinates)
    result = []
    segments = extracted_segments(coordinates)
    segments.each_with_index do |seg1, i|
      segments[(i + 1)..-1].each do |seg2|
        if !shared_endpoint_query(seg1, seg2) then
          if segment_intersection_query(seg1[:start], seg1[:end],
                                      seg2[:start], seg2[:end]) then
            result << [seg1[:pair], seg2[:pair]]
          end
        end
      end
    end
    result
  end

  private ###  Helper Calculations

  # All parent-child line segments in 'coordinates'
  # Returns: Array of segment hashes containing start, end, and pair info.
  def extracted_segments(coordinates)
    result = []
    coordinates.single_nodes.each_value do |node|
      person = node.person
      child_top = node.top_center
      if person.father then
        father_node = coordinates.node_for_person(person.father)
        if father_node then
          father_bottom = father_node.bottom_center
          result << {
            start: father_bottom,
            end: child_top,
            pair: [person.father.id, person.id]
          }
        end
      end
      if person.mother then
        mother_node = coordinates.node_for_person(person.mother)
        if mother_node then
          mother_bottom = mother_node.bottom_center
          result << {
            start: mother_bottom,
            end: child_top,
            pair: [person.mother.id, person.id]
          }
        end
      end
    end
    coordinates.couples.each_value do |couple|
      p1 = couple.person_a
      p2 = couple.person_b
      children = children_retriever(p1, p2)
      children.each do |child|
        child_top = coordinates.node_for_person(child)&.top_center
        if child_top then
          result << {
            start: couple.bottom_center,
            end: child_top,
            pair: ["#{p1.id}+#{p2.id}", child.id]
          }
        end
      end
    end
    result
  end

  def children_retriever(p1, p2)
    p1.children.select do |c|
      c.parents.include?(p1) || c.parents.include?(p2)
    end
  end

  def shared_endpoint_query(seg1, seg2)
    result = false
    p1, c1 = seg1[:pair]
    p2, c2 = seg2[:pair]
    if p1 == p2 || c1 == c2 then
      result = true
    end
    result
  end

  # Standard 2D line segment intersection test (CCW algorithm)
  def segment_intersection_query(p1, p2, p3, p4)
    result = false
    if
      counter_clockwise_orientation(p1, p3, p4) !=
      counter_clockwise_orientation(p2, p3, p4) &&
      counter_clockwise_orientation(p1, p2, p3) !=
      counter_clockwise_orientation(p1, p2, p4)
    then
      result = true
    end
    result
  end

  def counter_clockwise_orientation(a, b, c)
    (c[1] - a[1]) * (b[0] - a[0]) > (b[1] - a[1]) * (c[0] - a[0])
  end

end
