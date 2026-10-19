# vim: ts=2 sw=2 expandtab
require 'ruby_contracts'
require 'domain_tools'

# Abstract base class representing layout environment and shared configuration.
class LayoutEnvironment
  include Contracts::DSL

  public

  attr_reader :people, :roots, :coordinates, :options

  public  ###  Initialization

  pre :people_type do |people| people.is_a?(Enumerable) end
  pre :coords_type do |ppl, coords| coords.is_a?(Coordinates) end
  pre :options_type do |ppl, crds, options| options.is_a?(Enumerable) end
  def initialize(people, coordinates, options)
    @people = people
    @coordinates = coordinates
    @options = options
    @roots = DomainTools.roots(people, options)
  end

  public  ###  Basic queries

  # children or parents of 'person', based on configuration
  def branches(person)
    raise "virtual method"
  end

end
