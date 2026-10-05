# vim: ts=2 sw=2 expandtab
require 'layout_step'
require 'set'

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
    align_generations(people)
    correct_generation_gaps(people)
    align_generations(people)
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

  def align_generations(people)
    loop do
      changed = false
      # Align spouses
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
      # Align co-parents (parents sharing a child)
      people.each_value do |person|
        parents = person.parents
        if parents.size > 1 then
          max_gen = parents.map(&:generation).max
          parents.each do |parent|
            if parent.generation != max_gen then
              parent.generation = max_gen
              changed = true
            end
          end
        end
      end
      if !changed then
        break
      end
    end
  end

  def correct_generation_gaps(people)
    loop do
      changed = false
      people.each_value do |person|
        person.parents.each do |parent|
          if person.generation - parent.generation > 1 then
            target_parent_gen = person.generation - 1
            if parent.generation < target_parent_gen then
              adjust_ancestors_upward(parent.person, target_parent_gen)
              changed = true
            end
          end
        end
      end
      if !changed then
        break
      end
    end
  end

  def adjust_ancestors_upward(person, target_gen, visited = Set.new)
    return if visited.include?(person.id)
    visited.add(person.id)
    person.generation = target_gen
    person.spouses.each do |spouse|
      spouse.generation = target_gen
    end
    person.parents.each do |parent|
      adjust_ancestors_upward(parent.person, target_gen - 1, visited)
    end
  end

end
