# required libraries/tools
require 'ruby_contracts'

# application components
require_relative 'coordinates'
require_relative 'family_constants'

# Data structure that extracts genealogical data from a Person,
# recursively, treating the Person as the root of a tree, and uses
# this data to create an SVG-based graph.
class Graph
  include Contracts::DSL

  LEVEL_HEIGHT = 150
  COUPLE_SPACING = 140
  SIBLING_SPACING = 150

  public

  attr_reader :coordinates

  post 'invariant' do invariant end
  def initialize(person)
    @coordinates = Coordinates.new
    @next_x = Hash.new(0)
    add_coords(person, 0)
  end

  private

  # Add coordinates, recursively for 'p' to 'coordinates'.
  pre 'p_exists' do |p| p != nil end
  def add_coords(p, depth = 0)
    if p.has_spouse then
      add_spousal_coords(p, depth)
    else
      add_single_coords(p, depth)
    end
  end

  # Add coordinates, recursively for 'p' to 'coordinates'.
  pre 'p_valid_spouse' do |p| p != nil && p.has_spouse end
  def add_spousal_coords(p, depth)
    # Recursively place children first (bottom-up)
    p.children.each do |c|
      add_coords(c, depth + 1)
    end

    spouse = p.spouse
    add_couple_coords(p, spouse, depth)
  end

  pre 'p_valid_single' do |p| p != nil && !p.has_spouse end
  def add_single_coords(p, depth)
    # Recursively place children first (bottom-up)
    p.children.each do |c|
      add_coords(c, depth + 1)
    end

    add_individual_coords(p, depth)
  end

  # Add coordinates for person 'p' to 'coordinates'
  pre 'p_exists_indiv' do |p| p != nil end
  def add_individual_coords(p, depth)
    y = depth * LEVEL_HEIGHT

    if p.children.empty? then
      x = @next_x[y]
      @coordinates.add_node(p.id, x, y)
      @next_x[y] = x + SIBLING_SPACING
    else
      # Center over children
      child_xs = p.children.map { |c| @coordinates.node(c.id)[0] }
      min_x = child_xs.min
      max_x = child_xs.max
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
  pre 'valid_spouses' do |spouse1, spouse2|
    spouse1 != nil && spouse2 != nil
  end
  def add_couple_coords(spouse1, spouse2, depth)
    y = depth * LEVEL_HEIGHT
    @coordinates.add_couple(spouse1.id, spouse2.id)

    if spouse1.children.empty? then
      x1 = @next_x[y]
      x2 = x1 + COUPLE_SPACING
      @coordinates.add_node(spouse1.id, x1, y)
      @coordinates.add_node(spouse2.id, x2, y)
      @next_x[y] = x2 + SIBLING_SPACING
    else
      # Center over children
      child_xs = spouse1.children.map { |c| @coordinates.node(c.id)[0] }
      min_x = child_xs.min
      max_x = child_xs.max
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

      person.children.each do |child|
        shift_subtree(child, amount)
      end
    end
  end

  def invariant
    @coordinates != nil
  end
end
