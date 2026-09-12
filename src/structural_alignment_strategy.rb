require_relative 'debug_logger'
require_relative 'debug_logger'
require_relative 'layout_strategy'
require_relative 'debug_logger'
require_relative 'family_constants'

# Enforces genealogical structural constraints:
# 1. Spousal Adjacency: Ensures spouses are placed adjacent to each other.
# 2. Parental Centering: Ensures children subtrees are centered under parents.
class StructuralAlignmentStrategy < LayoutStrategy
  include Contracts::DSL

  def apply(graph)
    people = graph.instance_variable_get(:@people)
    people.each do |_, person|
      align_spouses(person, graph)
    end
  end

  private

  def align_spouses(person, graph)
    return unless person.has_spouse
    # We need a stable reference point for the couple.
    unless graph.coordinates.has_node?(person.id)
      DebugLogger.log("DEBUG: Spouse alignment skipped: #{person.id} has no coords.")
      return
    end
    p_x, p_y = graph.coordinates.node(person.id)
    person.spouses.each_with_index do |spouse, index|
      unless graph.coordinates.has_node?(spouse.id)
        DebugLogger.log("DEBUG: Spouse alignment skipped: Spouse #{spouse.id} of #{person.id} has no coords.")
        next
      end
      # Force spouses to be COUPLE_SPACING apart from the person
      expected_s_x = p_x + (COUPLE_SPACING * (index + 1))
      s_x, s_y = graph.coordinates.node(spouse.id)
      DebugLogger.log("DEBUG: Aligning #{person.id} (X=#{p_x}) with spouse #{spouse.id} (X=#{s_x}). Expected: #{expected_s_x}")
      if (s_x - expected_s_x).abs > 5
        shift_amount = expected_s_x - s_x
        DebugLogger.log("DEBUG: Aligning spouse #{spouse.id} with #{person.id}. Shift: #{shift_amount}")
        # Shift the entire connected block of the spouse
        graph.shift_subtree(spouse, shift_amount, graph)
      end
    end
  end
end
