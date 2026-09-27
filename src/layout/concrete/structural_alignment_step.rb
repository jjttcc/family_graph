# vim: ts=2 sw=2 expandtab
require 'ruby_contracts'
require 'layout_step'

class StructuralAlignmentStep < LayoutStep
  include Contracts::DSL

  public

  def execute
    people = context.people
    people.each_value do |person|
      align_spouses(person)
    end
  end

  private

  def align_spouses(person)
    if person.has_spouse then
      person.spouses.each do |spouse|
        couple = context.coordinates.node_for_couple(person, spouse)
        p1_node = context.coordinates.node_for_person(person)
        p2_node = context.coordinates.node_for_person(spouse)
        if couple && p1_node && p2_node then
          p1_node.y = couple.y
          p2_node.y = couple.y
        end
      end
    end
  end

end
