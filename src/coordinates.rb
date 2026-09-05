require 'ruby_contracts'

# Repository of coordinates and spousal pairings used to construct
# the final genealogical graph.
class Coordinates
  include Contracts::DSL

  public

  attr_reader :nodes, :couples

  ###  Initialization

  # Initialize coordinates with empty structures.
  post 'invariant' do invariant end
  def initialize
    @nodes = {}
    @couples = []
  end

  ###  Access

  # Retrieve coordinates for a given person.
  def node(id)
    @nodes[id]
  end

  ###  Status report

  # Check if a person has coordinates defined.
  def has_node?(id)
    @nodes.key?(id)
  end

  ###  Element change

  # Store coordinates for an individual person.
  pre 'valid_coords' do |id, x, y|
    id != nil && x.is_a?(Numeric) && y.is_a?(Numeric)
  end
  def add_node(id, x, y)
    @nodes[id] = [x, y]
  end

  # Register a spousal pairing.
  pre 'valid_spouses' do |spouse1, spouse2|
    spouse1 != nil && spouse2 != nil
  end
  def add_couple(spouse1, spouse2)
    # Store sorted pair to avoid duplicating (A, B) and (B, A)
    pair = [spouse1, spouse2].sort
    @couples << pair unless @couples.include?(pair)
  end

  private

  def invariant
    @nodes != nil && @couples != nil
  end
end
