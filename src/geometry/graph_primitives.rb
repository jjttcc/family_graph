require 'ruby_contracts'
require 'utilities'

# The abstract base class for all visual nodes within the family tree
# rendering pipeline, providing common position attributes.
class Node
  include Contracts::DSL

  public

  attr_accessor :x, :y

  public  ###  Access

  # The id of the underlying entity (e.g., person)
  def id
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
  def initialize(person, x = 0, y = 0)
    super(x, y)
    @person = person
    if ! invariant then raise "invariant violation" end
  end

  public  ###  Access

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

  private ###  Class invariant

  def invariant
    person.is_a?(Person)
  end

end

# Geometric node for a couple (atomic "couple" representation)
class CoupleNode < Node
  include Contracts::DSL, Utilities

  public

  attr_reader :partner_a, :partner_b

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
