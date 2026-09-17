# vim: ts=2 sw=2 expandtab
require 'debug_logger'
require 'layout_step'
require 'family_constants'

# Enforces genealogical structural constraints:
# 1. Spousal Adjacency: Ensures spouses are placed adjacent to each other.
# 2. Parental Centering: Ensures children subtrees are centered under parents.
class StructuralAlignmentStep < LayoutStep
  include Contracts::DSL

  public

  def execute(context)
    people = context.people
    people.each_value do |person|
      align_spouses(person, context)
    end
  end

  private

  def align_spouses(person, context)
    return unless person.has_spouse
    # We need a stable reference point for the couple.
    unless context.coordinates.has_node?(person.id)
      DebugLogger.log("DEBUG: Spouse alignment skipped: #{person.id} ",
                      "has no coords.")
      return
    end
    p_x, p_y = context.coordinates.node(person.id)
    person.spouses.each_with_index do |spouse, index|
      unless context.coordinates.has_node?(spouse.id)
        DebugLogger.log("DEBUG: Spouse alignment skipped: Spouse ",
                        "#{spouse.id} of #{person.id} has no coords.")
        next
      end
      # Force spouses to be COUPLE_SPACING apart from the person
      expected_s_x = p_x + (COUPLE_SPACING * (index + 1))
      s_x, s_y = context.coordinates.node(spouse.id)
      DebugLogger.log("DEBUG: Aligning #{person.id} (X=#{p_x}) ",
        "with spouse #{spouse.id} (X=#{s_x}). Expected: #{expected_s_x}")
      if (s_x - expected_s_x).abs > 5
        shift_amount = expected_s_x - s_x
        DebugLogger.log("DEBUG: Aligning spouse #{spouse.id} with ",
                        "#{person.id}. Shift: #{shift_amount}")
        # Shift the entire connected block of the spouse
        context.shift_subtree(spouse, shift_amount)
      end
    end
  end

end
