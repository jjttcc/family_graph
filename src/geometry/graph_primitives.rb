# Abstract base for all visual entities
class Node
  attr_accessor :x, :y
  def initialize(x = 0, y = 0)
    @x = x
    @y = y
  end
end

# Represents an individual person node
class PersonNode < Node
  attr_reader :person, :context_id
  def initialize(person, context_id, x = 0, y = 0)
    super(x, y)
    @person = person
    @context_id = context_id
  end
end

# Represents a couple node (atomic spousal representation)
class CoupleNode < Node
  attr_reader :spouse1, :spouse2
  def initialize(spouse1, spouse2, x = 0, y = 0)
    super(x, y)
    @spouse1 = spouse1
    @spouse2 = spouse2
  end
end

# Represents a relationship edge (e.g., parent-child)
class Edge
  attr_reader :from, :to
  def initialize(from, to)
    @from = from
    @to = to
  end
end
