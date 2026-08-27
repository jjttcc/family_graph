# required libraries/tools
require 'ruby_contracts'

# application components
require 'coordinates'

# Data structure that extracts genealogical data from a Person,
# recursively, treating the Person as the root of a tree, and uses
# this data to create an SVG-based graph.
class Graph
  public

  attr_reader :coordinates

  private

  # Add coordinates, recursively for 'p' to 'coordinates'.
  pre '"p" exists' do |p| p != null end
  def add_coords(p)
    if p.has_spouse then
      add_spousal_coords(p)
    else
      add_single_coords(p)
    end
  end

  # Add coordinates, recursively for 'p' to 'coordinates'.
  pre 'p_valid' do |p| p != null and p.has_spouse end
  def add_spousal_coords(p)
    spouse = p.spouse
    add_couple_coords(p, spouse)
    for c in p.children do
      add_coords(c)
    end
  end

  pre 'p_valid' do |p| p != null not p.has_spouse end
  def add_single_coords(p)
    add_individual_coords(p)
    for c in p.children do
      add_coords(c)
    end
  end

  # Add coordinates for person 'p' to 'coordinates'
  pre 'p_valid' do |p| p != null end
  def add_individual_coords(p)
    # to be implemented
  end

  # Add coordinates for the couple 'spouse' and 'spouse2' to 'coordinates'
  pre 'valid_spouses' do |spouse1, spouse2|
    spouse1 != null and spouse2 != null
  end
  def add_couple_coords(spouse1, spouse2)
    # to be implemented
  end

  private

  post 'invariant' do invariant end
  def initialize(person)
    @coordinates = Coordinates.new
    add_coords(person)
  end

  def invariant
    coordinates != null
  end

end
