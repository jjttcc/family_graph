require 'layout_step'
require 'family_constants'

# Calculates the required horizontal width for each parent's child-generation.
class WidthCalculatorStep < LayoutStep
  include Contracts::DSL

  public

  def execute(context)
    coords = context.coordinates
    coords.single_nodes.each_value do |node|
      node.offspring_width = calculate_node_offspring_width(node, context)
    end
    coords.couples.each_value do |couple_node|
      couple_node.offspring_width = calculate_couple_offspring_width(
        couple_node, context)
    end
  end

  private

  def calculate_node_offspring_width(node, context)
    person = node.person
    children = context.branches(person).select do |child|
      !person.has_spouse || child.parents.include?(person)
    end
    calculate_total_children_width(children)
  end

  def calculate_couple_offspring_width(couple_node, context)
    person_a = couple_node.person_a
    person_b = couple_node.person_b
    children = context.branches(person_a).select do |child|
      child.parents.include?(person_b)
    end
    calculate_total_children_width(children)
  end

  def calculate_total_children_width(children)
    if children.empty? then
      0
    else
      total_width = 0
      children.each do |child|
        if child.has_spouse then
          total_width += (2 * NODE_WIDTH) + COUPLE_SPACING
        else
          total_width += NODE_WIDTH
        end
      end
      total_width + ((children.size - 1) * SIBLING_SPACING)
    end
  end
end
