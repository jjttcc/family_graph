require_relative 'descendant_graph'
require_relative 'graph_renderer'
require_relative 'hierarchy_analyzer'
require_relative 'layout_compactor'

# Orchestrates the graph construction, and rendering process.
class GraphOrchestrator
  public

  def initialize(graph, roots, people, options)
    @graph = graph
    @roots = roots
    @people = people
    @options = options
  end

  def render
#binding.break
    # Execute graph construction
    graph.build(roots)
    # Run alignment if supported by the layout strategy
    if graph.instance_variable_get(:@layout).respond_to?(:align) then
      graph.instance_variable_get(:@layout).align(graph, people)
    end
    # Run compaction if supported by the layout strategy
    if graph.instance_variable_get(:@layout).respond_to?(:compact) then
      graph.instance_variable_get(:@layout).compact(graph, people)
    end
    # Render
    puts "Rendering SVG..."
    renderer = GraphRenderer.new(graph.coordinates, people,
                                 options[:direction],
                                 options[:label_mode])
    # Use the pre-determined roots
    root_ids = roots.map(&:id)
    suffix = root_ids.size == 1 ? root_ids.first : "unified"
    renderer.render(options[:output_dir], suffix)
  end

  private

  attr_reader :people, :roots, :graph, :options

end
