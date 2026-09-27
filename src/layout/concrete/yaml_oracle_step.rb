require 'yaml'
require 'layout_step'

# A debug/verification step that serializes the current state
# of the coordinate registry to a YAML file.
class YamlOracleStep < LayoutStep

  public

  def initialize(filename, context)
    super(context)
    @filename = filename
  end

  def execute
    data = {
      nodes: context.coordinates.single_nodes,
      couples: context.coordinates.couples,
      next_x: context.coordinates.instance_variable_get(:@next_x)
    }
    File.write(@filename, data.to_yaml)
    puts "Oracle snapshot saved to #{@filename}"
  end

end
