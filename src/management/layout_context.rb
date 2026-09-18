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

  def update_person(person, x, y, other_person_id = nil)
    person.send(:add_coordinate_set, x, y, other_person_id)
    @coordinates.add_node(person.id, x, y)
  end

  def shift_person(person, dx, dy)
    coord = person.self_coordinates
    return unless coord
    update_person(person, coord[0] + dx, coord[1] + dy)
  end

  def shift_subtree(person, dx, dy = 0)
    return unless person
    shift_person(person, dx, dy)
    if person.has_spouse
      person.spouses.each { |spouse| shift_person(spouse, dx, dy) }
    end
    branches(person).each { |child| shift_subtree(child, dx, dy) }
  end

=begin
  # Note: 'attr_reader :coordinates' will already allow the contents of
  # @coordinates to be changed. Therefore, this method is not needed and
  # should be removed.
  # Expose coordinates for next_x manipulation
  def coordinates
    @coordinates
  end
=end

end
