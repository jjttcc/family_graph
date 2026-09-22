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

end
