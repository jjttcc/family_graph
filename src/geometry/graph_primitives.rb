require 'ruby_contracts'
require 'utilities'
require 'family_constants'

# The abstract base class for all visual nodes within the family tree
# rendering pipeline, providing common position attributes.
class Node
  include Contracts::DSL

  public

  attr_accessor :x, :y, :offspring_width

  public  ###  Queries

  # The id of the underlying entity (e.g., person)
  def id
    raise "virtual method"
  end

  # The horizontal center coordinate of the node
  def center_x
    raise "virtual method"
  end

  # The top-center coordinates [x, y] of the node
  def top_center
    raise "virtual method"
  end

  # The bottom-center coordinates [x, y] of the node
  def bottom_center
    raise "virtual method"
  end

  # The width of the node
  def width
    raise "virtual method"
  end

  public  ###  Initialization

  pre :xy_valid do |x, y| x != nil && y != nil end
  def initialize(x = 0, y = 0)
    @x = x
    @y = y
  end

end

# Geometric node for a person
class PersonNode < Node
  include Contracts::DSL

  public

  attr_reader :person

  public  ###  Initialization

  pre :xy_valid do |p, x, y| x != nil && y != nil end
  pre :person_valid do |person| person.is_a?(Person) end
  def initialize(person, x = 0, y = 0, is_primary_representation = true)
    super(x, y)
    @person = person
    @is_primary_representation = is_primary_representation
    if ! invariant then raise "invariant violation" end
  end

  public  ###  Access

  attr_accessor :is_primary_representation

  # The id of 'person'
  pre  :inv do invariant end
  post :inv do invariant end
  def id
    person.id
  end

  def given_name
    person.given_name
  end

  def surname
    person.surname
  end

  def birth_date
    person.birth_date
  end

  # The horizontal center coordinate of this person node
  def center_x
    x + (NODE_WIDTH / 2.0)
  end

  # The top-center coordinates [x, y] of this person node
  def top_center
    [x + (NODE_WIDTH / 2.0), y]
  end

  # The bottom-center coordinates [x, y] of this person node
  def bottom_center
    [x + (NODE_WIDTH / 2.0), y + NODE_HEIGHT]
  end

  # The width of the node
  def width
    NODE_WIDTH
  end

  def method_missing(method_name, *args, &block)
    if person.respond_to?(method_name) then
      person.send(method_name, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    person.respond_to?(method_name) || super
  end

  private ###  Class invariant

  def invariant
    person.is_a?(Person)
  end

end

# Geometric node for a couple (atomic "couple" representation)
class CoupleNode < Node
  include Contracts::DSL, Utilities
  extend Utilities

  public

  attr_reader :partner_a, :partner_b

  # Generates a standard ID for a couple given two persons.
  def self.generate_id(person1, person2)
    # Using the joined_id helper logic from Utilities.
    joined_id(person1.id, person2.id)
  end

  pre :nodes_valid do |p1, p2| p1.is_a?(PersonNode) && p2.is_a?(PersonNode) end
  pre :coords_valid do |p1, p2, x, y| x != nil && y != nil end
  post :inv do invariant end
  def initialize(partner_a, partner_b, x = 0, y = 0)
    @partner_a = partner_a
    @partner_b = partner_b
    super(x, y)
  end

  public  ###  Access

  # The ids of 'partner_a' and 'partner_b', sorted and joined together.
  def id
    joined_id(partner_a.id, partner_b.id)
  end

  # The 'partner_a' person
  def person_a
    partner_a.person
  end

  # The 'partner_b' person
  def person_b
    partner_b.person
  end

  # The horizontal center coordinate of this couple node
  def center_x
    (partner_a.center_x + partner_b.center_x) / 2.0
  end

  # The top-center coordinates [x, y] of this couple node
  def top_center
    [center_x, y]
  end

  # The bottom-center coordinates [x, y] of this couple node
  def bottom_center
    [center_x, y + NODE_HEIGHT]
  end

  # The width of the node
  def width
    COUPLE_WIDTH
  end

  # Initializes coordinates for this couple and its partner nodes
  def initialize_coordinates(new_x, new_y)
    @x = new_x
    @y = new_y
    partner_a.x = new_x
    partner_a.y = new_y
    partner_b.x = new_x + NODE_WIDTH + 20
    partner_b.y = new_y
  end

  public  ###  Boolean queries

  # Does this "couple" contain 'person1' and 'person2'?
  def is_match(person1, person2)
    self.id == joined_id(person1.id, person2.id)
  end

  private ###  Class invariant

  def invariant
    person_a.is_a?(Person) && person_b.is_a?(Person) &&
    partner_a.is_a?(PersonNode) && partner_b.is_a?(PersonNode)
  end

end

# Relationship edges (e.g., parent-child)
class Edge

  include Contracts::DSL

  public

  attr_reader :from, :to

  pre :nodes_valid do |f, t| f.is_a?(Node) && t.is_a?(Node) end
  def initialize(from, to)
    @from = from
    @to = to
  end

end
