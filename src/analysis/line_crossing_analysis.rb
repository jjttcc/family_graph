# vim: ts=2 sw=2 expandtab
require 'ruby_contracts'
require 'family_constants'

# Objects that perform analysis of parent-child connection lines in the
# coordinate layout to detect and report intersecting line segments
class LineCrossingAnalysis
  include Contracts::DSL

  public ###  Initialization

  def initialize(coordinates)
    @coordinates = coordinates
  end

  public ###  Analysis Queries

  # Analyzes the coordinate registry and returns an array of crossing
  # line pairs.
  # The result of analysis of the coordinate registry:
  #   Array of "line pairs"
  # Each pair is represented as [[parent1, child1], [parent2, child2]].
  def crossing_pairs
    result = []
    segments = extracted_segments(@coordinates)
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
    coordinates.all_person_nodes.each do |node|
      if node.is_a?(PersonNode) && node.is_primary_representation then
        person = node.person
        child_top = node.top_center
        person.parents.each do |parent|
          parent_node = coordinates.node_for_person(parent)
          if parent_node then
            parent_bottom = parent_node.bottom_center
            result << {
              start: parent_bottom,
              end: child_top,
              pair: [parent.id, person.id]
            }
          end
        end
      end
    end
    result
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
    if counter_clockwise_orientation(p1, p3, p4) !=
       counter_clockwise_orientation(p2, p3, p4) &&
       counter_clockwise_orientation(p1, p2, p3) !=
       counter_clockwise_orientation(p1, p2, p4) then
      result = true
    end
    result
  end

  def counter_clockwise_orientation(a, b, c)
    (c[1] - a[1]) * (b[0] - a[0]) > (b[1] - a[1]) * (c[0] - a[0])
  end

  private

  attr_reader :coordinates

end
