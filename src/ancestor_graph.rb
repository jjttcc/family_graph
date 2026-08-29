# required libraries/tools
require 'ruby_contracts'

# application components
require_relative 'graph'
require_relative 'coordinates'
require_relative 'family_constants'

# Graph objects that traverse upward, over ancestors
class AncestorGraph < Graph

  public

  private ### Hook method implementations

  pre 'person_exists_indiv' do |person| person != nil end
  post 'invariant' do invariant end
  def initialize(person)
    init_attributes
    add_coords(person, 0, false)
  end

  def branches(p)
    p.parents
  end

end
