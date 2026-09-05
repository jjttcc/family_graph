# [please add a description here, Gemini.]
class HierarchyAnalyzer

  def self.calculate_generations(people)
    generations = {}
    # Initial pass: Find all true roots (nodes with no parents)
    # and all other nodes that need to be linked
    roots = people.values.select { |p| p.parents.empty? }
    roots.each { |root| assign_generation(root, 0, generations) }
    # Assign generations to all objects
    people.each do |id, person|
      person.instance_variable_set(:@generation, generations[id] || 0)
    end
  end

  # depth-first search to assign generations
  # A person's generation is the maximum generation of their parents + 1
  # For roots, generation = 0
  def self.assign_generation(person, gen, generations)
    if generations.key?(person.id) && generations[person.id] >= gen then
      # [null-op]
    else
      generations[person.id] = gen
      person.children.each do |child|
        assign_generation(child, gen + 1, generations)
      end
    end
  end

end
