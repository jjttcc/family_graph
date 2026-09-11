require_relative 'debug_logger'
# required libraries/tools
require 'ruby_contracts'

# Represents a person in the family tree, storing biographical and
# genealogical data.
class Person
  include Contracts::DSL

  public

  attr_reader :id, :children, :generation
  attr_accessor :spouses, :father, :mother

  public  ###  Initialization

  def initialize(id, data = {})
    @id = id
    DebugLogger.log("DEBUG: Creating Person #{id} (OID: #{self.object_id}")
    @data = data
    @spouses = []
    @children = []
    @coordinate_sets = {} # Maps spouse_id (or nil) to [x, y]
  end

  public  ###  Access

  # The coordinate set for self's relation to the person with person_id
  def coordinate_set(person_id = nil)
    result = @coordinate_sets[person_id]
    if result.nil?
      DebugLogger.log(
        "DEBUG: coordinate_set(#{person_id.inspect}) for #{id}" +
        "(OID: #{self.object_id}) is nil! Available sets: " +
        "#{@coordinate_sets.keys.inspect}")
    end
    result
  end

  # self's first spouse
  def spouse
    @spouses.first
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

  # Does self have a spouse?
  def has_spouse
    !@spouses.empty?
  end

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

  # Add the specified coordinate set with respect to the relation to
  # the person with person_id.
  def add_coordinate_set(x, y, person_id = nil)
    DebugLogger.log("DEBUG: Storing coord for #{id} " +
      "(OID: #{self.object_id}): (#{x}, #{y}) for #{person_id.inspect}")
    @coordinate_sets[person_id] = [x, y]
  end

  public  ###  Dynamic queries

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
    parents.empty? == is_root
  end

end
