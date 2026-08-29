# required libraries/tools
require 'ruby_contracts'

# application components
require_relative 'graph'
require_relative 'coordinates'
require_relative 'family_constants'

# Graph objects that traverse downward, over descendants
class DescendantGraph < Graph

  public

  private ### Hook method implementations

  def branches(p)
    p.children
  end

end
