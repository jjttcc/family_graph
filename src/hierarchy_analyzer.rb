require 'ruby_contracts'

# Analyzes genealogical data to assign a generational rank to each person
# based on their longest path from a root ancestor.
class HierarchyAnalyzer
  include Contracts::DSL

  public

  # Calculate and assign the generational rank of each person in the
  # provided people collection. Ensures spouses are aligned to the same
  # generation level.
  def calculate_and_assign_generations(people)
    generations = {}
    people.each_value { |person| assign_generation(person, generations) }
    people.each_value do |person|
      person.instance_variable_set(:@generation, generations[person.id] || 0)
    end
    align_spouses(people)
  end

  private

  # Assign a generation value to the specified person and store it in the
  # generations mapping, if it has not already been assigned.
  def assign_generation(person, generations)
    if !generations.key?(person.id) then
      generations[person.id] = calculated_generation(person, generations)
    end
  end

  # The generation value of the specified person, "calculated" recursively -
  # tracing parents back to root ancestors.
  # Side effect: Caches the calculated value in the generations mapping.
  post :not_nil do |result| result != nil end
  def calculated_generation(person, generations)
    result = nil
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

  # Align spouses until all generational differences within spouse
  # groups have propagated to a stable state.
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
