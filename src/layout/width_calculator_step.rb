require 'layout_step'
require 'family_constants'

# Calculates the required horizontal width for each parent's child-generation.
class WidthCalculatorStep < LayoutStep
  include Contracts::DSL

  public

  # Executes the width calculator step, populating offspring_width
  # for all nodes.
  def execute(context)
    coords = context.coordinates
    coords.single_nodes.each_value do |node|
      node.offspring_width = node_offspring_width(node, context)
    end
    coords.couples.each_value do |couple_node|
      width = couple_offspring_width(couple_node, context)
      couple_node.offspring_width = width
      couple_node.partner_a.offspring_width = width
      couple_node.partner_b.offspring_width = width
    end
    coords.set_nodes_initialized
  end

  private

  # Offspring width for a singleton person node.
  def node_offspring_width(node, context)
    person = node.person
    children = context.branches(person).select do |child|
      !person.has_spouse || child.parents.include?(person)
    end
    children_width(children)
  end

  # Offspring width for a couple node.
  def couple_offspring_width(couple_node, context)
    person_a = couple_node.person_a
    person_b = couple_node.person_b
    children = context.branches(person_a).select do |child|
      child.parents.include?(person_a) || child.parents.include?(person_b)
    end
    children_width(children)
  end

  # Total width required for a group of children.
  def children_width(children)
    result = 0
    if ! children.empty? then
      children.each do |child|
        if child.has_spouse then
          result += (2 * NODE_WIDTH) + COUPLE_SPACING
        else
          result += NODE_WIDTH
        end
      end
      result += ((children.size - 1) * SIBLING_SPACING)
    end
    result
  end

end
