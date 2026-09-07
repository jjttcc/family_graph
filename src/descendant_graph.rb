# required libraries/tools
require 'ruby_contracts'

# application components
require_relative 'graph'
require_relative 'coordinates'
require_relative 'family_constants'
require_relative 'simple_layout'

# Graph objects that traverse downward, over descendants
class DescendantGraph < Graph

  public

  def branches(p)
    p.children
  end

end
