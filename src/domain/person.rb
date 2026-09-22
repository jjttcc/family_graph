require 'debug_logger'
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

  post :invariant do invariant end
  def initialize(id, data = {})
    @id = id
    DebugLogger.log("DEBUG: Creating Person #{id} (OID: #{self.object_id}")
    @data = data
    @spouses = []
    @children = []
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
