require 'ruby_contracts'
require 'utilities'
require 'graph_primitives'

# Repository of nodes and spousal pairings used to construct the layout.
class Coordinates
  include Contracts::DSL, Utilities

  public

  attr_reader :nodes, :couples

  public  ###  Initialization

  # Initialize registry with empty structures.
  post 'invariant' do invariant end
  def initialize
    @nodes = {}
    @couples = {}
    @next_x = Hash.new(0)
  end

  public  ###  Access

  # The node with node-id of 'id'
  post :nil_or_node do |result|
    result == nil || result.is_a?(PersonNode)
  end
  def node(id)
    self.nodes[id]
  end

  # The node associated with 'person'
  pre 'valid_person' do |person| person.is_a?(Person) end
  post :nil_or_node do |result|
    result == nil || result.is_a?(Node)
  end
  def node_for_person(person)
    result = @nodes.values.find { |n| n.person.id == person.id }
    if result == nil then
      result = @couples.values.find do |c|
        c.person_a.id == person.id || c.person_b.id == person.id
      end
    end
    result
  end

  # couple for 'id'
  post :nil_or_node do |result|
    result == nil || result.is_a?(CoupleNode)
  end
  def couple(id)
    self.couples[id]
  end

  # The next available x position for a given y level.
  def next_x(y)
    @next_x[y]
  end

  ###  Status report

  # Check if a person has a registered node.
  def has_node?(id)
    self.nodes.key?(id)
  end

  public  ###  Element change

  # Store Node instance for a person.
  pre 'valid_node' do |node| node.is_a?(PersonNode) end
  def add_node(node)
    @nodes[node.id] = node
  end

  # Register a couple.
  pre :valid_node do |node| node.is_a?(CoupleNode) end
  def add_couple(node)
    self.couples[node.id] = node
  end

  # Update next available x position for a given y level.
  def update_next_x(y, value)
    @next_x[y] = value
  end

  private

  def invariant
    nodes != nil && couples != nil &&
    nodes.values.all? { |n| n.is_a?(Node) } &&
    couples.values.all? { |n| n.is_a?(Node) }
  end

end
