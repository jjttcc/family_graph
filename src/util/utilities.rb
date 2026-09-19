
module Utilities

  # id1 and id2 joined together, sorted, separated by 'sep'
  def joined_id(id1, id2, sep = '.')
    [id1, id2].sort.join(sep)
  end

end
