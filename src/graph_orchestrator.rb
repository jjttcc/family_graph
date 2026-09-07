require_relative 'data_loader'
require_relative 'descendant_graph'
require_relative 'ancestry_dataset'
require_relative 'graph_renderer'
require_relative 'hierarchy_analyzer'
require_relative 'layout_compactor'

# Orchestrates the data loading, graph construction, and rendering process.
class GraphOrchestrator
  public

  def initialize(graph, roots, options, data_paths)
    @graph = graph
    @roots = roots
    @options = options
    @data_paths = data_paths
  end

  def render
    people = load_data

    # Execute graph construction
    @graph.build(@roots)

    # Run compaction if supported by the layout strategy
    if @graph.instance_variable_get(:@layout).respond_to?(:compact)
      @graph.instance_variable_get(:@layout).compact(@graph, people)
    end

    # Render
    puts "Rendering SVG..."
    renderer = GraphRenderer.new(@graph.coordinates, people, 
                                 @options[:direction],
                                 @options[:label_mode])
    root_ids = determine_roots(people)
    suffix = root_ids.size == 1 ? root_ids.first : "unified"
    renderer.render(@options[:output_dir], suffix)
  end

  private

  def load_data
    people = {}
    @data_paths.each do |path|
      unless File.exist?(path)
        puts "Error: Data file '#{path}' not found."
        next
      end
      puts "Loading data from #{path}..."
      people.merge!(DataLoader.load(path))
    end
    people
  end

  def determine_roots(people)
    all_roots = people.select { |_id, p| p.father.nil? && p.mother.nil? }
    if @options[:root_ids] && @options[:root_ids].include?("{all}")
      all_roots.keys
    else
      @options[:root_ids] || all_roots.keys
    end
  end

end
