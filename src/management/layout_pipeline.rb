# A simple, flat pipeline that delegates layout operations to a sequence
# of individual layout strategy components.
class LayoutPipeline
  def initialize(strategies = [])
    @strategies = strategies
  end

  def execute(contxt)
    @strategies.each { |s| s.execute(contxt) }
  end

  def shift_subtree(person, amount)
    @strategies.each do |s|
      s.shift_subtree(person, amount)
    end
  end

end
