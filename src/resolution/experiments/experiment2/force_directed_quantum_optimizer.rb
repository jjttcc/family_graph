# vim: ts=2 sw=2 expandtab
#!/usr/bin/env ruby

root = 'FG_ROOT'
root_path = ENV[root]
setup_path = "#{root_path}/setup.rb"
if ! ENV[root] then
  $stderr.puts "environment variable #{root} must be set."
  exit 2
end
require setup_path
require 'coordinates'
require 'line_crossing_analysis'
require 'data_loader'
require 'layout_context'
require 'hierarchy_analyzer_step'
require 'hierarchical_placement_step'

# Experiment 2: Multidimensional Force-Directed Spring Relaxation with Quantum Tunneling.
# Treats nodes as charged particles in 2D continuous space subject to spring attraction,
# node repulsion, crossing torque, and quantum teleportation jolts.
class ForceDirectedQuantumOptimizer
  public ###  Execution

  def initialize(yaml_filename = 'sample_tree_line_crossing.yaml', iterations = 50)
    @yaml_filename = yaml_filename
    @iterations = iterations
  end

  # Executes the force-directed simulation loop.
  def optimize
    yaml_path = File.join(__dir__, '..', 'experiment1', 'data', @yaml_filename)
    if !File.exist?(yaml_path) then
      # Fallback to general data path
      yaml_path = File.join(__dir__, '..', '..', '..', 'data', @yaml_filename)
    end

    if !File.exist?(yaml_path) then
      $stderr.puts "YAML file not found: #{yaml_path}"
      exit 1
    end

    puts "Experiment 2: Loading tree from #{@yaml_filename}..."
    people = DataLoader.load(yaml_path)
    root_person = people.values.find { |p| p.father.nil? && p.mother.nil? }
    if !root_person then
      root_person = people.values.first
    end

    coordinates = Coordinates.new
    context = LayoutContext.new(people, [root_person], coordinates, { TRAVERSAL => DESCENDANT })

    analyzer_step = HierarchyAnalyzerStep.new(context)
    analyzer_step.execute

    placement_step = HierarchicalPlacementStep.new(context)
    placement_step.execute

    analyzer = LineCrossingAnalysis.new(coordinates)
    initial_crossings = analyzer.crossing_pairs.size
    puts "Experiment 2 Initial Crossings: #{initial_crossings}"

    all_nodes = coordinates.all_person_nodes

    @iterations.times.each do |iteration|
      # Apply spring forces and repulsion
      apply_forces(all_nodes, coordinates)

      # Quantum tunneling jolt every 15 iterations if crossings persist
      if iteration > 0 && iteration % 15 == 0 && analyzer.crossing_pairs.size > 0 then
        apply_quantum_tunneling(all_nodes)
      end

      crossings = analyzer.crossing_pairs.size
      if iteration % 10 == 0 then
        puts "Iteration #{iteration}: Crossings = #{crossings}"
      end
    end

    final_crossings = analyzer.crossing_pairs.size
    puts "Experiment 2 Final Crossings: #{final_crossings}"
    final_crossings
  end

  private ###  Force Calculations & Physics Simulation

  # Applies simple vector forces between connected nodes and mutually between all nodes.
  def apply_forces(nodes, coordinates)
    # Simple relaxation step: nudge nodes based on neighbor X/Y discrepancy
    nodes.each do |node|
      if node.is_a?(PersonNode) && node.person then
        person = node.person
        # Pull towards parents' average X
        parents = [person.father, person.mother].compact
        if !parents.empty? then
          parent_x_sum = parents.map { |p| coordinates.node_for_person(p)&.x || node.x }.sum
          avg_parent_x = parent_x_sum / parents.size.to_f
          # Gentle spring pull
          node.x += (avg_parent_x - node.x) * 0.1
        end

        # Repel overlapping nodes
        nodes.each do |other|
          if other != node && (other.x - node.x).abs < 50 && (other.y - node.y).abs < 50 then
            if other.x >= node.x then
              node.x -= 5
              other.x += 5
            else
              node.x += 5
              other.x -= 5
            end
          end
        end
      end
    end
  end

  # Applies random quantum displacement to escape local gravitational traps.
  def apply_quantum_tunneling(nodes)
    puts "Quantum tunneling jolt applied to escape local energy minimum..."
    nodes.each do |node|
      if rand < 0.3 then
        quantum_shift = (rand(50) - 25)
        node.x += quantum_shift
      end
    end
  end

end

if __FILE__ == $0 then
  optimizer = ForceDirectedQuantumOptimizer.new('sample_tree_line_crossing.yaml', 40)
  optimizer.optimize
end
