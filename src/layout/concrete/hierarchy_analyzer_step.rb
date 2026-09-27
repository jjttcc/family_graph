# vim: ts=2 sw=2 expandtab
require 'layout_step'

class HierarchyAnalyzerStep < LayoutStep
  include Contracts::DSL

  public

  def execute
    generations = {}
    people = context.people
    people.each_value do |person|
      assign_generation(person, generations)
    end
    # assign the associated generation (generations[person.id]) to each
    # person in 'people'.
    people.each_value do |person|
      if generations[person.id] != nil then
        person.generation = generations[person.id]
      else
        person.generation = 0
      end
    end
    align_spouses(people)
  end

  private

  # Assigns a generational rank to the specified person and memoizes it in
  # the generations hash. Parameters:
  #   - person [Person]: The person whose generation is being determined (read-
  #     only; not modified).
  #   - generations [Hash]: Hash mapping person IDs to generation integers
  #     (mutated to store memoized results).
  def assign_generation(person, generations)
    if !generations.key?(person.id) then
      parents = person.parents
      if parents.empty? then
        generations[person.id] = 0
      else
        parents.each { |p| assign_generation(p, generations) }
        parent_gens = parents.map { |p| generations[p.id] }
        generations[person.id] = parent_gens.max + 1
      end
    end
  end

  def align_spouses(people)
    loop do
      changed = false
      people.each_value do |person|
        person.spouses.each do |spouse|
          max_gen = [person.generation, spouse.generation].max
          if person.generation != max_gen || spouse.generation != max_gen then
            person.generation = max_gen
            spouse.generation = max_gen
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
