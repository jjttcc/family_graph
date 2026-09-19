# vim: ts=2 sw=2 expandtab
require 'ruby_contracts'

# Provides the context necessary for a layout step to perform its work.
# It acts as a read-only provider for the people and roots.
class LayoutContext
  include Contracts::DSL

  public

  attr_reader :people, :roots, :coordinates

  def initialize(people, roots, coordinates, traversal_direction)
    @people = people
    @roots = roots
    @coordinates = coordinates
    @traversal_direction = traversal_direction
  end

  def branches(person)
    @traversal_direction == ANCESTOR ? person.parents : person.children
  end

=begin
  def update_person(person, x, y, other_person_id = nil)
$stderr.puts "'update_person' is obsolete returning..."; return
    person.send(:add_coordinate_set, x, y, other_person_id)
    # Use context_id if other_person_id is nil
    context_id = other_person_id || Person::SELF
    node = PersonNode.new(person, context_id, x, y)
    @coordinates.add_node(node)
  end

  def shift_person(person, dx, dy)
raise
$stderr.puts "'LayoutContext.shift_person' is obsolete"; return
    coord = person.self_coordinates
    return unless coord
    update_person(person, coord[0] + dx, coord[1] + dy)
  end

  def shift_subtree(person, dx, dy = 0)
raise
$stderr.puts "'LayoutContext.shift_subtree' is obsolete?"; return
    return unless person
    shift_person(person, dx, dy)
    if person.has_spouse
      person.spouses.each { |spouse| shift_person(spouse, dx, dy) }
    end
    branches(person).each { |child| shift_subtree(child, dx, dy) }
  end
=end

end
