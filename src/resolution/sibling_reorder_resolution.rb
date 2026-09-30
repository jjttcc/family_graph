# vim: ts=2 sw=2 expandtab
require 'line_crossing_resolution'

# Resolves line crossings by reordering/reversing sibling group X coordinates.
class SiblingReorderResolution < LineCrossingResolution
  public ###  Execution

  def execute(crossings)
    parent_ids = crossings.map { |c| [c[0][0], c[1][0]] }.flatten.uniq
    parent_ids.each do |pid|
      parent_person = coordinates.single_nodes[pid]&.person ||
                      coordinates.all_person_nodes.find do |n|
                        n.id == pid
                      end&.person
      if parent_person && !parent_person.children.empty? then
        child_nodes = parent_person.children.map do |c|
          coordinates.node_by_person_id(c.id)
        end.compact
        if child_nodes.size > 1 then
          x_coords = child_nodes.map(&:x).sort
          child_nodes.each_with_index do |cn, idx|
            cn.x = x_coords[-(idx + 1)]
          end
        end
      end
    end
  end

end
