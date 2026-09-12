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
    # The layout strategy now handles the entire placement pass.
    # We call it once at the top level of traversal.
    @layout.apply(self)
  end

  # Orchestration method for the layout pipeline.
  def perform_layout
    @layout.apply(self)
  end

  public ### Hook methods

  def branches(p)
    raise "virtual method"
  end

  public ### Structural manipulation

  # Recursively shift coordinates of a subtree and update next_x
  def shift_subtree(person, amount, graph)
    @layout.shift_subtree(person, amount, graph)
  end

  private ###  Class invariant

  def invariant
    @coordinates != nil
  end

end
