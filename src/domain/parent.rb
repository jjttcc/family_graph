require 'ruby_contracts'
require 'family_constants'

# Abstract base class for parents (biological or non-biological)
class Parent
  include Contracts::DSL

  public

  # The 'person' this parent is representing
  attr_reader :person

  public ###  Initialization

  pre :person_valid do |person| person.is_a?(Person) end
  def initialize(person)
    @person = person
  end

  public  ###  Access

  def id
    person.id
  end

  # Type of parent: BIOLOGICAL, ADOPTIVE, etc.
  def type
    raise "virtual method"
  end

  public  ###  Boolean queries

  # Is this a biological parent?
  def is_biological
    raise "virtual method"
  end

  public  ###  Type matching

  def is_a?(klass)
    if klass == Person then
      true
    else
      super
    end
  end

  alias_method :kind_of?, :is_a?

  def ==(other)
    result = false
    if other.is_a?(Parent) then
      result = self.person == other.person
    elsif other.is_a?(Person) then
      result = self.person == other
    end
    result
  end

  public  ### Dynamic queries and procedures

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

end
