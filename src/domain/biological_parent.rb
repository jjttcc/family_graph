require 'parent'

# Represents a biological parent
class BiologicalParent < Parent

  public  ###  Access

  def type
    BIOLOGICAL
  end

  public  ###  Boolean queries

  def is_biological
    true
  end

end
