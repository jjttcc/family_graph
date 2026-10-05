require 'debug_logger'
require 'ruby_contracts'
require 'parent'
require 'biological_parent'
require 'non_biological_parent'

# Represents a person in the family tree, storing biographical and
# genealogical data.
class Person
  include Contracts::DSL
  include DebugLogger

  public

  attr_reader :id, :children
  # biological father and mother (type Parent)
  attr_accessor :father, :mother
  attr_accessor :spouses, :generation
  # All of self's non-biological mothers (array of NonBiologicalParent)
  attr_accessor :non_biological_mothers
  # All of self's non-biological fathers (array of NonBiologicalParent)
  attr_accessor :non_biological_fathers

  public  ###  Initialization

  post :invariant do invariant end
  def initialize(id, data = {})
    @id = id
    log("DEBUG: Creating Person #{id} (OID: #{self.object_id}")
    @data = data
    @spouses = []
    @children = []
    @non_biological_mothers = []
    @non_biological_fathers = []
  end

  public  ###  Access

  def given_name
    @data[GNAME]
  end

  def surname
    @data[SURNAME]
  end

  def birth_date
    @data[BDATE]
  end

  public  ### Retrieval

  # Parents - mother and father - of self. These parents may be biological
  # or non-biological, and there may be more than two parents - for
  # example, in the case in which a person has a biological mother, was
  # given up for adoption and as a result also has a 'adoptive' mother.
  # Array[Parent]: empty if no parents
  post :result_good do |result| result.is_a?(Array) end
  post :first_parent_check do |result|
    implies(result.count > 0, result[0].is_a?(Parent))
  end
  def parents
    result = []
    if ! mother.nil? then
      result << mother
    end
    if ! father.nil? then
      result << father
    end
    if non_biological_mothers then
      result.concat(non_biological_mothers)
    end
    if non_biological_fathers then
      result.concat(non_biological_fathers)
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

  private ###  Implementation

  # Dynamic access for evolving fields
  # Maps underscores to hyphens for seamless YAML lookup
  # (e.g. given_name -> given-name).
  def method_missing(method_name, *args, &block)
    if @data.nil? then
      return super
    end
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
    if @data.nil? then
      return false
    end
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
