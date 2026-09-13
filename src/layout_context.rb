# vim: ts=2 sw=2 expandtab

# Provides the context necessary for a layout step to perform its work.
# It acts as a read-only provider for the people and roots.
class LayoutContext
  attr_reader :people, :roots, :coordinates

  def initialize(people, roots, coordinates, traversal_direction)
    @people = people
    @roots = roots
    @coordinates = coordinates
    @traversal_direction = traversal_direction
  end

  def branches(person)
    @traversal_direction == :ancestor ? person.parents : person.children
  end

  def shift_subtree(person, amount)
    # This needs implementation, probably delegating to InitialPlacementStep? 
    # Or moving the implementation from InitialPlacementStep here?
    # Let's start with a stub.
  end
end
