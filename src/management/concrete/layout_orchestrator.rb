# vim: ts=2 sw=2 expandtab
require 'layout_context'
require 'graph_renderer'
require 'family_constants'
require 'coordinates'

# Orchestrates the layout pipeline and rendering process.
class LayoutOrchestrator

  public

  attr_accessor :context

  # Initializes the orchestrator with the layout pipeline and context.
  def initialize(pipeline, cntxt)
    @pipeline = pipeline
    @context = cntxt
  end

  # Runs the layout pipeline and renders the graph.
  def render
    puts "Running layout pipeline..."
    pipeline.each do |step|
      step.execute
    end
    # Render
    puts "Rendering SVG..."
    renderer = GraphRenderer.new(context.coordinates,
                                 context.options[DIRECTION],
                                 context.options[:label_mode])
    # Use the pre-determined roots
    root_ids = context.roots.map(&:id)
    suffix = root_ids.size == 1 ? root_ids.first : "unified"
    renderer.render(context.options[:output_dir], suffix)
  end

  private

  attr_reader :pipeline

end
