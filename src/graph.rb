# required libraries/tools
require 'ruby_contracts'

# application components
require_relative 'coordinates'
require_relative 'family_constants'

# Data structure that extracts genealogical data from a list of Person
# objects, recursively, treating the Person as the root of a tree, and uses
# this data to create an SVG-based graph.
class Graph
  include Contracts::DSL

  public

  attr_reader :coordinates

  public  ###  Initialization

  post 'invariant' do invariant end
  def initialize(layout_strategy)
    init_attributes
    @layout = layout_strategy
  end

  # Perform data traversal and layout execution.
  pre :people_exist do |people| people != nil end
  def build(people)
    target_people = people
    if !target_people.is_a?(Array) then
      target_people = [target_people]
    end
    target_people.each do |p|
      add_coords(p)
    end
  end

  private ###  Initialization

  def init_attributes
    @coordinates = Coordinates.new
    @next_x = Hash.new(0)
  end

  private ###  Implementation

  # Add coordinates, recursively for 'p' to 'coordinates'.
  pre :p_exists do |p| p != nil end
  def add_coords(p)
    if p.has_spouse then
      add_spousal_coords(p)
    else
      add_single_coords(p)
    end
  end

  # Add coordinates, recursively for 'p' and its spouse to 'coordinates'.
  pre :p_valid_spouse do |p| p != nil && p.has_spouse end
  def add_spousal_coords(p)
    # Recursively place branches first
    branches(p).each do |b|
      if ! b.nil? then
        add_coords(b)
      end
    end
    spouse = p.spouse
    @layout.add_couple(p, spouse, self)
  end

  # Add coordinates, recursively for 'p' to 'coordinates'.
  pre :p_valid_single do |p| p != nil && ! p.has_spouse end
  def add_single_coords(p)
    # Recursively place branches first
    branches(p).each do |b|
      if ! b.nil? then
        add_coords(b)
      end
    end
    @layout.add_individual(p, self)
  end

  public ### Hook methods

  def branches(p)
    raise "virtual method"
  end

  public ### Structural manipulation

  # Recursively shift coordinates of a subtree and update next_x
  def shift_subtree(person, amount)
    @layout.shift_subtree(person, amount, self)
  end

  private ###  Class invariant

  def invariant
    @coordinates != nil
  end

end
