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

# Experiment 3: Ising Spin Glass & Magnetic Dipole Domain-Flip Optimizer.
# Treats tree hierarchical sibling groups as magnetic spins on a lattice.
# Energy of the system is proportional to LineCrossingAnalysis crossing count.
# Minimizes energy via Monte Carlo spin-glass domain flips and magnetic field induction.
class IsingSpinGlassOptimizer
  public ###  Execution

  def initialize(yaml_filename = 'sample_tree_line_crossing.yaml', monte_carlo_steps = 100)
    @yaml_filename = yaml_filename
    @monte_carlo_steps = monte_carlo_steps
  end

  # Executes the spin-glass monte carlo optimization simulation.
  def optimize
    yaml_path = File.join(__dir__, '..', 'experiment1', 'data', @yaml_filename)
    if !File.exist?(yaml_path) then
      yaml_path = File.join(__dir__, '..', '..', '..', 'data', @yaml_filename)
    end

    if !File.exist?(yaml_path) then
      $stderr.puts "YAML file not found: #{yaml_path}"
      exit 1
    end

    puts "Experiment 3 (Spin Glass): Loading tree from #{@yaml_filename}..."
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
    initial_energy = analyzer.crossing_pairs.size
    best_energy = initial_energy
    puts "Experiment 3 Initial Spin-Glass Energy (Crossings): #{initial_energy}"

    temperature = 10.0

    @monte_carlo_steps.times.each do |step|
      current_energy = analyzer.crossing_pairs.size
      break if current_energy == 0

      # Select random person node and flip/mirror its sibling sequence (magnetic domain flip)
      person_nodes = coordinates.all_person_nodes.select { |n| n.is_a?(PersonNode) && n.person && !n.person.children.empty? }
      if !person_nodes.empty? then
        target_node = person_nodes.sample
        person = target_node.person
        children = person.children.map { |c| coordinates.node_by_person_id(c.id) }.compact

        if children.size > 1 then
          # Snapshot current spin state (X coordinates)
          old_spins = children.map(&:x)

          # Apply magnetic domain flip (invert X ordering)
          sorted_x = children.map(&:x).sort.reverse
          children.each_with_index { |child, idx| child.x = sorted_x[idx] }

          new_energy = analyzer.crossing_pairs.size
          delta_e = new_energy - current_energy

          accept = false
          if delta_e <= 0 then
            accept = true
          else
            boltzmann_factor = Math.exp(-delta_e.to_f / [temperature, 0.0001].max)
            if rand < boltzmann_factor then
              accept = true
            end
          end

          if accept then
            if new_energy < best_energy then
              best_energy = new_energy
              puts "MC Step #{step + 1}: Spin domain flip reduced energy to #{best_energy}"
            end
          else
            # Revert magnetic domain flip
            children.each_with_index { |child, idx| child.x = old_spins[idx] }
          end
        end
      end

      temperature *= 0.98
    end

    final_energy = analyzer.crossing_pairs.size
    puts "Experiment 3 Final Spin-Glass Energy: #{final_energy}"
    final_energy
  end

end

if __FILE__ == $0 then
  optimizer = IsingSpinGlassOptimizer.new('sample_tree_line_crossing.yaml', 60)
  optimizer.optimize
end
