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

  LEVEL_HEIGHT = 150
  COUPLE_SPACING = 140
  SIBLING_SPACING = 150

  public

  attr_reader :coordinates

  public  ###  Initialization

  pre :people_exist do |people| people != nil end
  post 'invariant' do invariant end
  def initialize(people)
    init_attributes
    if ! people.is_a?(Array) then
      people = [people]
    end
    people.each { |p| add_coords(p) }
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
    add_couple_coords(p, spouse)
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
    add_individual_coords(p)
  end

  protected ### Hook methods

  def branches(p)
    raise "virtual method"
  end

  private ###  Implementation

  # Add coordinates for person 'p' to 'coordinates'
  pre :p_exists_indiv do |p| p != nil end
  def add_individual_coords(p)
    y = p.generation * LEVEL_HEIGHT
    b = branches(p)
    if b.empty? then
      x = @next_x[y]
      @coordinates.add_node(p.id, x, y)
      @next_x[y] = x + SIBLING_SPACING
    else
      # Center over branches
      branch_xs = b.map { |br| @coordinates.node(br.id)[0] }
      min_x = branch_xs.min
      max_x = branch_xs.max
      midpoint = (min_x + max_x) / 2
      parent_x = midpoint
      if parent_x < @next_x[y] then
        shift_amount = @next_x[y] - parent_x
        shift_subtree(p, shift_amount)
        parent_x = @next_x[y]
      end
      @coordinates.add_node(p.id, parent_x, y)
      @next_x[y] = parent_x + SIBLING_SPACING
    end
  end

  # Add coordinates for the couple 'spouse1' and 'spouse2'
  pre :valid_spouses do |spouse1, spouse2|
    spouse1 != nil && spouse2 != nil
  end
  def add_couple_coords(spouse1, spouse2)
    y = spouse1.generation * LEVEL_HEIGHT
    @coordinates.add_couple(spouse1.id, spouse2.id)
    if branches(spouse1).empty? then
      x1 = @next_x[y]
      x2 = x1 + COUPLE_SPACING
      @coordinates.add_node(spouse1.id, x1, y)
      @coordinates.add_node(spouse2.id, x2, y)
      @next_x[y] = x2 + SIBLING_SPACING
    else
      # Center over branches
      branch_xs = branches(spouse1).map { |b| @coordinates.node(b.id)[0] }
      min_x = branch_xs.min
      max_x = branch_xs.max
      midpoint = (min_x + max_x) / 2
      parent_x1 = midpoint - (COUPLE_SPACING / 2)
      parent_x2 = parent_x1 + COUPLE_SPACING
      if parent_x1 < @next_x[y] then
        shift_amount = @next_x[y] - parent_x1
        shift_subtree(spouse1, shift_amount)
        parent_x1 = @next_x[y]
        parent_x2 = parent_x1 + COUPLE_SPACING
      end
      @coordinates.add_node(spouse1.id, parent_x1, y)
      @coordinates.add_node(spouse2.id, parent_x2, y)
      @next_x[y] = parent_x2 + SIBLING_SPACING
    end
  end


  # Recursively shift coordinates of a subtree and update next_x
  def shift_subtree(person, amount)
    if person != nil then
      if @coordinates.has_node?(person.id) then
        x, y = @coordinates.node(person.id)
        new_x = x + amount
        @coordinates.add_node(person.id, new_x, y)
        @next_x[y] = [@next_x[y], new_x + SIBLING_SPACING].max
      end
      if person.has_spouse then
        spouse = person.spouse
        if @coordinates.has_node?(spouse.id) then
          x, y = @coordinates.node(spouse.id)
          new_x = x + amount
          @coordinates.add_node(spouse.id, new_x, y)
          @next_x[y] = [@next_x[y], new_x + SIBLING_SPACING].max
        end
      end
      branches(person).each do |branch|
        shift_subtree(branch, amount)
      end
    end
  end

  private ###  Class invariant

  def invariant
    @coordinates != nil
  end

end
