require 'layout_step'

class HierarchyAnalyzerStep < LayoutStep
  include Contracts::DSL

  public

  def execute
    generations = {}
    context.people.each_value do |person|
      assign_generation(person, generations)
    end
    context.people.each_value do |person|
      person.generation = generations[person.id]
    end
  end

  private

  def assign_generation(person, generations)
    return generations[person.id] if generations.key?(person.id)

    parents = context.branches(person)
    if parents.empty? then
      generations[person.id] = 0
    else
      parent_gens = parents.map { |p| assign_generation(p, generations) }
      generations[person.id] = parent_gens.max + 1
    end
    generations[person.id]
  end

end
