# vim: ts=2 sw=2 expandtab
require_relative '../line_crossing_resolution'

# Experimental stochastic sibling reorder resolution with randomized shuffles
# and perturbations to escape local minima in line crossing optimization.
class StochasticSiblingReorderResolution < LineCrossingResolution
  public ###  Execution

  # Initializes with coordinates and optional random seed.
  def initialize(coordinates, seed = nil)
    super(coordinates)
    @seed = seed
    if @seed then
      srand(@seed)
    end
  end

  # Resolves line crossings by applying randomized shuffles or reversals
  # to sibling groups of parents involved in crossing pairs.
  def execute(crossings)
    parent_ids = extract_parent_ids(crossings)
    parent_ids.each do |parent_id|
      parent_person = find_parent_person(parent_id)
      if parent_person && !parent_person.children.empty? then
        perturb_siblings(parent_person)
      end
    end
  end

  private ###  Helper Calculations

  # Extracts unique parent identifiers from crossing pairs.
  def extract_parent_ids(crossings)
    crossings.map do |crossing|
      [crossing[0][0], crossing[1][0]]
    end.flatten.uniq
  end

  # Finds the Person object corresponding to a parent identifier.
  def find_parent_person(parent_id)
    single_node = coordinates.single_nodes[parent_id]
    parent_person = nil
    if single_node then
      parent_person = single_node.person
    else
      person_node = coordinates.all_person_nodes.find do |node|
        node.id == parent_id
      end
      if person_node then
        parent_person = person_node.person
      end
    end
    parent_person
  end

  # Perturbs child nodes of a parent person using randomized shuffles
  # or sorted permutations.
  def perturb_siblings(parent_person)
    child_nodes = parent_person.children.map do |child|
      coordinates.node_by_person_id(child.id)
    end.compact
    if child_nodes.size > 1 then
      x_coordinates = child_nodes.map(&:x).sort
      # Apply random shuffle or reverse based on random choice
      permutation_type = rand(3)
      if permutation_type == 0 then
        x_coordinates = x_coordinates.reverse
      elsif permutation_type == 1 then
        x_coordinates = x_coordinates.shuffle
      else
        # Keep sorted or shift circularly
        shift_amount = rand(x_coordinates.size)
        x_coordinates = x_coordinates.rotate(shift_amount)
      end

      child_nodes.each_with_index do |child_node, index|
        child_node.x = x_coordinates[index]
      end
    end
  end

end
