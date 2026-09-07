# required libraries/tools
require 'ruby_contracts'

# application components
require_relative 'graph'
require_relative 'coordinates'
require_relative 'family_constants'
require_relative 'initial_placement_strategy'

# Graph objects that traverse downward, over descendants
class DescendantGraph < Graph

  public

  def branches(p)
    p.children
  end

end
