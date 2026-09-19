require 'debug_logger'
# required libraries/tools
require 'ruby_contracts'

# Represents a person in the family tree, storing biographical and
# genealogical data.
class Person
  include Contracts::DSL

  public

  attr_reader :id, :children, :generation, :coordinate_sets
  attr_accessor :spouses, :father, :mother

  SELF = '<self>'

  public  ###  Initialization

  post :invariant do invariant end
  def initialize(id, data = {})
    @id = id
    DebugLogger.log("DEBUG: Creating Person #{id} (OID: #{self.object_id}")
    @data = data
    @spouses = []
    @children = []
    @coordinate_sets = {} # Maps spouse_id (or nil) to [x, y]
    @coordinate_sets[SELF] = [0, 0]
  end

  public  ###  Access

  def given_name
    @data[GNAME]
  end

  def surname
    @data[SURNAME]
  end

  public  ### Retrieval

  # The coordinate set for self's relation to the person with person_id
  #   - person.coordinate_set [no args] (or person.coordinate_set(SELF))
  #     is the coordinate set for the person itself.
  #   - person.coordinate_set(spousex.id) is the coordinate set for
  #     the person's 'spousex' spouse.
  pre :invariant do invariant end   ## !!to-do: Comment out for performance
  post :valid_for_pid_self do |result, person_id|
    implies(person_id == SELF || person_id.nil?, result != nil)
  end
  def coordinate_set(person_id = SELF)
    if person_id.nil? then
      person_id = SELF
    end
=begin # for debugging:
if person_id == SELF and coordinate_sets.count > 1 then
  raise "accessing coord set for SELF instead of for a spouse?"
end
=end
    result = @coordinate_sets[person_id]
    if result.nil?
      DebugLogger.log(
        "DEBUG: coordinate_set(#{person_id.inspect}) for #{id}" +
        "(OID: #{self.object_id}) is nil! Available sets: " +
        "#{@coordinate_sets.keys.inspect}")
    end
    result
  end

  # The element of 'coordinate_sets' that represents 'self'
  def self_coordinates
    @coordinate_sets[SELF]
  end

  # Biological mother and father - list: empty if no parents
  post :result_good do |result| not result.nil? end
  post :only_two do |result| result.count <= 2 end
  post :mother do |result|
    implies(! self.mother.nil?, result.include?(self.mother))
  end
  post :mother do |result|
    implies(! self.father.nil?, result.include?(self.father))
  end
  def parents
    result = []
    if ! mother.nil? then
      result << mother
    end
    if ! father.nil? then
      result << father
    end
    result
  end

  public  ###  Boolean queries

  # Does self have one or more spouses?
  def has_spouse
    !@spouses.empty?
  end

  alias is_married has_spouse

  # Is self a root node (has no parents)?
  def is_root
    parents.empty?
  end

  public  ###  Element change

  pre do |person| not self.children.include?(person) end
  def add_child(person)
    @children << person
  end

  pre do |person| ! @spouses.include?(person) end
  def add_spouse(person)
    @spouses << person
  end

  protected ###  Restricted interface

  # Add the specified coordinate set with respect to the relation to
  # the person with person_id (who could be, for example, a spouse).
  post :valid_for_pid_self do |result, person_id|
    implies(person_id == SELF || person_id.nil?, result != nil)
  end
  def add_coordinate_set(x, y, person_id = SELF)
    if person_id.nil? then
      person_id = SELF
    end
    DebugLogger.log("DEBUG: Storing coord for #{id} ",
      "(OID: #{self.object_id}): (#{x}, #{y}) for #{person_id.inspect}")
    @coordinate_sets[person_id] = [x, y]
  end

  private ###  Implementation

  # Dynamic access for evolving fields
  # Maps underscores to hyphens for seamless YAML lookup
  # (e.g. given_name -> given-name).
  def method_missing(method_name, *args, &block)
    m_str = method_name.to_s
    if @data.key?(m_str) then
      return @data[m_str]
    end
    hyphenated = m_str.gsub('_', '-')
    if @data.key?(hyphenated) then
      return @data[hyphenated]
    end
    super
  end

  def respond_to_missing?(method_name, include_private = false)
    m_str = method_name.to_s
    hyphenated = m_str.gsub('_', '-')
    @data.key?(m_str) || @data.key?(hyphenated) || super
  end

  private ###  Implementation

  attr_reader :data

  private ###  Invariant

  def invariant
    parents.empty? == is_root && coordinate_sets.all? { |e| e != nil }
  end

end
