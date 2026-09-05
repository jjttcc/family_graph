# Analyzes genealogical data to assign a generational rank to each person
# based on their longest path from a root ancestor.
class HierarchyAnalyzer

  public

  def self.calculate_generations(people)
    generations = {}
    people.each { |id, person| assign_generation(person, generations) }
    people.each do |id, person|
      person.instance_variable_set(:@generation, generations[id] || 0)
    end
  end

  private

  # Recursive method to assign generation based on longest ancestor path
  def self.assign_generation(person, generations)
    if generations.key?(person.id) then
      result = generations[person.id]
    elsif person.parents.empty? then
      result = 0
      generations[person.id] = result
    else
      max_parent_gen = person.parents.map { |p|
        assign_generation(p, generations) }.max
      result = max_parent_gen + 1
      generations[person.id] = result
    end
    result
  end

end
