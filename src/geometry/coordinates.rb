require 'ruby_contracts'
require 'utilities'
require 'graph_primitives'

# Registry of nodes and spousal pairings used to construct the layout.
class Coordinates
  include Contracts::DSL, Utilities

  public

  attr_reader :single_nodes    # Hash: "PersonNode"s containing single persons
  attr_reader :couples         # Hash: "CoupleNode"s - married couples
  # Have all nodes in 'all_person_nodes' been initialized - prepared for
  # layout operations?
  attr_reader :nodes_initialized

  public  ###  Initialization

  # Initialize registry with empty structures.
  post :invariant do invariant end
  post :not_nodes_init do @nodes_initialized == false end
  def initialize
    @single_nodes = {}
    @couples = {}
    @next_x = Hash.new(0)
    @nodes_initialized = false
  end

  public  ###  Access

  # Array: All individual person nodes (singles + partners in couples)
  def all_person_nodes
    @single_nodes.values + @couples.values.flat_map { |c| [c.partner_a,
                                                           c.partner_b] }
  end

  # PersonNode from the registry (i.e., single_nodes and couples) associated
  # with 'id', (a person id)
  post :nil_or_node do |result|
    result == nil || result.is_a?(PersonNode)
  end
  def node_by_person_id(id)
    result = @single_nodes[id]
    if result == nil then
      @couples.values.each do |c|
        if c.partner_a.id == id then
          result = c.partner_a
        elsif c.partner_b.id == id then
          result = c.partner_b
        end
        if result != nil then
          break
        end
      end
    end
    result
  end

  # The node (PersonNode) associated with 'person'
  pre 'valid_person' do |person| person.is_a?(Person) end
  post :nil_or_node do |result|
    result == nil || result.is_a?(PersonNode)
  end
  def node_for_person(person)
    node_by_person_id(person.id)
  end

  # The couple node (CoupleNode) associated with 'person1' and 'person2'
  pre 'valid_persons' do |p1, p2| p1.is_a?(Person) && p1.is_a?(Person) end
  post :nil_or_node do |result|
    result == nil || result.is_a?(CoupleNode)
  end
  def node_for_couple(person1, person2)
    @couples[CoupleNode.generate_id(person1, person2)]
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
    self.single_nodes.key?(id) || @couples.values.any? do |c|
      c.person_a.id == id || c.person_b.id == id
    end
  end

  # Check if a couple is already registered.
  def has_couple?(id)
    self.couples.key?(id)
  end

  # Check if a couple is already registered for these two persons.
  def has_couple_for_persons?(p1, p2)
    has_couple?(CoupleNode.generate_id(p1, p2))
  end

  public  ###  Status setting

  # Set 'nodes_initialized' to true (i.e., all nodes in 'all_person_nodes'
  # have prepared for layout operations).
  post :invariant do invariant end
  def set_nodes_initialized
    @nodes_initialized = true
  end

  public  ###  Element change

  # Register a single node.
  pre :valid_node do |node| node.is_a?(PersonNode) end
  pre :has_person do |node| node.person.is_a?(Person) end
  pre :not_married do |node| ! node.person.is_married end
  post :invariant do invariant end
  def add_single_node(node)
    @single_nodes[node.id] = node
  end

  # Register a couple.
  pre :valid_node do |node| node.is_a?(CoupleNode) end
  post :invariant do invariant end
  def add_couple(node)
    self.couples[node.id] = node
  end

  # Update next available x position for a given y level.
  def update_next_x(y, value)
    @next_x[y] = value
  end

  private

  def invariant
    single_nodes != nil && couples != nil &&
    single_nodes.values.all? do |n|
      n.is_a?(PersonNode) && ! n.person.is_married
    end &&
    couples.values.all? { |n| n.is_a?(CoupleNode) } &&
    implies(nodes_initialized, all_person_nodes.all? { |n|
      n.offspring_width != nil })
  end

end
