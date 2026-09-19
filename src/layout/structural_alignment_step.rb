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
    unless context.coordinates.has_node?(person.id) then
      DebugLogger.log(["DEBUG: Spouse alignment skipped: #{person.id}",
                       "has no coords."], "\n")
      return
    end
    node = context.coordinates.node(person.id)
    p_x = node.x
    person.spouses.each_with_index do |spouse, index|
      unless context.coordinates.has_node?(spouse.id) then
        DebugLogger.log(["DEBUG: Spouse alignment skipped: Spouse ",
                         "#{spouse.id} of #{person.id} has no coords."], "\n")
        next
      end
      spouse_node = context.coordinates.node(spouse.id)
      expected_s_x = p_x + (COUPLE_SPACING * (index + 1))
      s_x = spouse_node.x
      if (s_x - expected_s_x).abs > 5 then
        shift_amount = expected_s_x - s_x
        # Shift the entire connected block of the spouse
        context.shift_subtree(spouse, shift_amount)
      end
    end
  end

end
