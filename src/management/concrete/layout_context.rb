# vim: ts=2 sw=2 expandtab
require 'ruby_contracts'
require 'layout_environment'

# Provides the context necessary for a layout step to perform its work.
# It acts as a read-only provider, with queries 'people', 'roots', 'coordinates', and 'options'.
class LayoutContext < LayoutEnvironment
  include Contracts::DSL

  public

  attr_accessor :offspring_generation_widths

  def initialize(people, roots, coordinates, options)
    super(people, roots, coordinates, options)
    @offspring_generation_widths = {}
  end

  def branches(person)
    @options[TRAVERSAL] == ANCESTOR ? person.parents : person.children
  end

end
