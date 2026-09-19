# Abstract base for all visual entities
require 'ruby_contracts'
require 'utilities'

class Node
  include Contracts::DSL

  public

  attr_accessor :x, :y

  public  ###  Access

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
  pre :not_married do |person| ! person.is_married end
  def initialize(person, x = 0, y = 0)
    super(x, y)
    @person = person
  end

  public  ###  Access

  def id
    person.id
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

  def id
    joined_id(partner_a.id, partner_b.id)
  end

  def person_a
    partner_a.person
  end

  def person_b
    partner_b.person
  end

  private ###  Class invariant

  def invariant
    person_a.is_a?(Person) && person_b.is_a?(Person)
  end

end

# Represents a relationship edge (e.g., parent-child)
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
