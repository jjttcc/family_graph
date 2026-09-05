require_relative 'data_loader'
require_relative 'descendant_graph'
require_relative 'ancestry_dataset'
require_relative 'graph_renderer'
require_relative 'hierarchy_analyzer'

# Orchestrates the data loading, graph construction, and rendering process.
class GraphOrchestrator
  def initialize(options, data_paths)
    @options = options
    @data_paths = data_paths
  end

  def render
    people = load_data
    root_ids = determine_roots(people)

    # Calculate generations
    HierarchyAnalyzer.calculate_generations(people)

    # Prepare roots
    roots = root_ids.map { |id| people[id] }.compact

    if roots.empty?
      puts "Error: No roots to render."
      return
    end

    # Build unified graph
    if @options[:traversal] == :ancestor
      # Simplified handling for ancestor traversal based on updated implementation requirements

      # For now, replicate the logic for single root if requested
      root_id = root_ids.first
      dataset = AncestryDataset.new(people[root_id], people)
      data_to_render = DataLoader.load_subset(@data_paths[0], dataset.ancestor_ids)

      # Re-calculate generations for the subset
      HierarchyAnalyzer.calculate_generations(data_to_render)

      graph = DescendantGraph.new(data_to_render[dataset.roots.first.id])

      # Render
      puts "Rendering SVG..."
      renderer = GraphRenderer.new(graph.coordinates, data_to_render, 
                                   @options[:direction],
                                   @options[:label_mode])
      renderer.render(@options[:output_dir], root_id)
    else
      # Unified rendering for descendants
      graph = DescendantGraph.new(roots)

      # Render
      puts "Rendering SVG..."
      renderer = GraphRenderer.new(graph.coordinates, people, 
                                   @options[:direction],
                                   @options[:label_mode])

      suffix = root_ids.size == 1 ? root_ids.first : "unified"
      renderer.render(@options[:output_dir], suffix)
    end
  end
...
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
    if @options[:root_ids] && @options[:root_ids].include?("all")
      all_roots.keys
    else
      @options[:root_ids] || all_roots.keys
    end
  end
end
