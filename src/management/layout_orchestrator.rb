# vim: ts=2 sw=2 expandtab
require 'layout_context'
require 'graph_renderer'
require 'family_constants'
require 'coordinates'

# Orchestrates the layout pipeline and rendering process.
class LayoutOrchestrator

  public

  # Initializes the orchestrator with graph context and pipeline.
  # Graph is now obsolete, we use Coordinates directly.
  def initialize(roots, people, pipeline, options)
    @pipeline = pipeline
    @options = options
    @coordinates = Coordinates.new # Local coordinate management
    @context = LayoutContext.new(people, roots, @coordinates,
                                 options[TRAVERSAL])
  end

  # Runs the layout pipeline and renders the graph.
  def render
    puts "Running layout pipeline..."
    pipeline.each do |step|
      step.execute(context)
    end
    # Render
    puts "Rendering SVG..."
    people = context.people
    renderer = GraphRenderer.new(context.coordinates, people,
                                 options[DIRECTION],
                                 options[:label_mode])
    # Use the pre-determined roots
    root_ids = context.roots.map(&:id)
    suffix = root_ids.size == 1 ? root_ids.first : "unified"
    renderer.render(options[:output_dir], suffix)
  end

  private

  attr_reader :options, :context, :pipeline, :coordinates

end
