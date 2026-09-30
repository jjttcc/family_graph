# vim: ts=2 sw=2 expandtab
require 'ruby_contracts'

# Abstract base class for line crossing resolution strategies.
class LineCrossingResolution
  include Contracts::DSL

  public

  attr_accessor :coordinates

  public ###  Initialization

  def initialize(coordinates)
    @coordinates = coordinates
  end

  public ###  Execution

  def execute(crossings)
    raise NotImplementedError,
      "#{self.class} #execute must be implemented in subclasses."
  end

end
