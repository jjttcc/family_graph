require 'parent'

# Represents a non-biological parent (assumed, adoptive, etc.)
class NonBiologicalParent < Parent
  public

  attr_reader :type

  pre :type_valid do |person, type| type != nil end
  def initialize(person, type)
    super(person)
    @type = type
  end

  public  ###  Boolean queries

  def is_biological
    false
  end

end
