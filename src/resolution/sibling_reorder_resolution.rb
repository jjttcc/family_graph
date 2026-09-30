# vim: ts=2 sw=2 expandtab
require 'line_crossing_resolution'

# Resolves line crossings by reordering sibling group X coordinates.
class SiblingReorderResolution < LineCrossingResolution
  public ###  Execution

  # Resolves line crossings by reversing sibling group X coordinates
  # for parent nodes involved in crossing pairs.
  def execute(crossings)
    parent_ids = extract_parent_ids(crossings)
    parent_ids.each do |parent_id|
      parent_person = find_parent_person(parent_id)
      if parent_person && !parent_person.children.empty? then
        reorder_siblings(parent_person)
      end
    end
  end

  private ###  Helper Calculations

  # Extracts unique parent identifiers from crossing pairs.
  def extract_parent_ids(crossings)
    crossings.map do |crossing|
      [crossing[0][0], crossing[1][0]]
    end.flatten.uniq
  end

  # Finds the Person object corresponding to a parent identifier.
  def find_parent_person(parent_id)
    single_node = coordinates.single_nodes[parent_id]
    parent_person = nil
    if single_node then
      parent_person = single_node.person
    else
      person_node = coordinates.all_person_nodes.find do |node|
        node.id == parent_id
      end
      if person_node then
        parent_person = person_node.person
      end
    end
    parent_person
  end

  # Reorders the child nodes of a parent person by reversing their
  # sorted X coordinates.
  def reorder_siblings(parent_person)
    child_nodes = parent_person.children.map do |child|
      coordinates.node_by_person_id(child.id)
    end.compact
    if child_nodes.size > 1 then
      x_coordinates = child_nodes.map(&:x).sort
      child_nodes.each_with_index do |child_node, index|
        child_node.x = x_coordinates[-(index + 1)]
      end
    end
  end

end
