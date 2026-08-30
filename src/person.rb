# required libraries/tools
require 'ruby_contracts'

class Person
  include Contracts::DSL

  public

  attr_reader :id, :children
  attr_accessor :spouses, :father, :mother, :father_id, :mother_id

  public  ###  Initialization

  def initialize(id, data = {})
    @id = id
    @data = data
    @spouses = []
    @children = []
  end

  public  ###  Access

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

  public  ###  Element change

  pre do |person| not self.children.include?(person) end
  def add_child(person)
    @children << person
  end

  pre do |person| ! @spouses.include?(person) end
  def add_spouse(person)
    @spouses << person
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

  public  ###### to-do!!!: make this private:

  attr_reader :data

  private ###  Implementation

end
