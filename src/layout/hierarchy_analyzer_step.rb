require 'layout_step'

# Analyzes genealogical data to assign a generational rank to each person.
class HierarchyAnalyzerStep < LayoutStep
  include Contracts::DSL

  public

  def execute(context)
    generations = {}
    context.people.each_value do |person|
      assign_generation(person, generations)
    end
    context.people.each_value do |person|
      person.instance_variable_set(:@generation, generations[person.id] || 0)
    end
    align_spouses(context.people)
  end

  private

  def assign_generation(person, generations)
    if !generations.key?(person.id) then
      generations[person.id] = calculated_generation(person, generations)
    end
  end

  def calculated_generation(person, generations)
    result = 0
    if generations.key?(person.id) then
      result = generations[person.id]
    elsif person.parents.empty? then
      result = 0
      generations[person.id] = result
    else
      max_parent_gen = person.parents.map { |p|
        calculated_generation(p, generations)
      }.max
      result = max_parent_gen + 1
      generations[person.id] = result
    end
    result
  end

  def align_spouses(people)
    loop do
      changed = false
      people.each_value do |person|
        person.spouses.each do |spouse|
          max_gen = [person.generation, spouse.generation].max
          if person.generation != max_gen || spouse.generation != max_gen then
            person.instance_variable_set(:@generation, max_gen)
            spouse.instance_variable_set(:@generation, max_gen)
            changed = true
          end
        end
      end
      if !changed then
        break
      end
    end
  end
end
