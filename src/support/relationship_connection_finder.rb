# Encapsulates logic for finding the correct coordinate representation
# of a person within a specific genealogical context.
class RelationshipConnectionFinder

  public

  def initialize(people)
    @people = people
  end

  # Returns the coordinate [x, y] for a person in a given context (spouse_id)
  # or falls back to SELF representation.
  def find(person, context_id)
    # 1. Try to find the coordinate set for the specific context
    coord = person.coordinate_set(context_id)
    # 2. Fallback to the default (SELF) representation
    if coord.nil? then
      coord = person.self_coordinates
      DebugLogger.log(["DEBUG: Finder fallback to SELF for #{person.id}",
                       "context: #{context_id.inspect}"], "\n")
    else
      DebugLogger.log(["DEBUG: Finder found coord for #{person.id}",
                       "context: #{context_id.inspect}",
                       "coord: #{coord.inspect}"], "\n")
    end
    coord
  end

end
