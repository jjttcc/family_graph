# vim: ts=2 sw=2 expandtab
require 'line_crossing_resolution'

# Resolves line crossings by swapping X coordinates of individual child nodes.
class NodeSwapResolution < LineCrossingResolution
  public ###  Execution

  def execute(crossings)
    crossings.each do |crossing|
      pair1, pair2 = crossing
      _, child1_id = pair1
      _, child2_id = pair2
      node1 = coordinates.node_by_person_id(child1_id) ||
                coordinates.couple(child1_id)
      node2 = coordinates.node_by_person_id(child2_id) ||
                coordinates.couple(child2_id)
      if node1 && node2 then
        temp_x = node1.x
        node1.x = node2.x
        node2.x = temp_x
      end
    end
  end

end
