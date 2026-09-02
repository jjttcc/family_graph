# Detailed Design: Unified Multi-Root Rendering

## 1. Goal
Refactor `family_graph` to render a single SVG diagram for multiple provided
root node IDs, rather than separate diagrams for each.

## 2. Component Refactoring

### 2.1. `src/graph.rb` (Graph Base Class)
- **Change `initialize(person)`**:
    - Rename parameter to `persons` (expecting a collection).
    - **Logic**:
        - Retain `init_attributes` for `@coordinates` and `@next_x`.
        - Replace single `add_coords(person, 0)` call with:
          ```ruby
          persons.each { |p| add_coords(p, 0) }
          ```
    - **Implication**: `add_coords` and its helper methods
      (`add_individual_coords`, `add_couple_coords`) rely on `@next_x` to
      determine the X-offset based on existing nodes at a given depth
      (`y`). Iterating sequentially through roots will naturally place them
      side-by-side.

### 2.2. New Orchestrator (`src/graph_orchestrator.rb`)
- **Responsibility**: Extract orchestration logic from `main.rb`.
- **Interface**:
    ```ruby
    class GraphOrchestrator
      def initialize(options, data_paths)
        @options = options
        @data_paths = data_paths
      end

      def render
        people = load_data
        root_ids = determine_roots(people)
        # Prepare roots
        roots = root_ids.map { |id| people[id] }
        # Build unified graph
        graph = DescendantGraph.new(roots) # Updated Constructor
        # Render
        renderer = GraphRenderer.new(graph.coordinates, people, ...)
        renderer.render(@options[:output_dir], "unified_graph")
      end
    end
    ```

### 2.3. `src/main.rb` (Updated Entry Point)
- **Role**:
    - Handle CLI argument parsing (`OptionParser`).
    - Instantiate `GraphOrchestrator`.
    - Invoke `orchestrator.render`.

## 3. Implementation Plan
1. **Design Approval**: Review and refine this detailed plan.
2. **Draft Orchestrator**: Create `src/graph_orchestrator.rb` based on logic
   extracted from `main.rb`.
3. **Refactor Graph**: Apply changes to `src/graph.rb` to support
   multiple roots.
4. **Integration**: Update `main.rb` to use `GraphOrchestrator`.
5. **Testing**: Add a new regression test (in `spec/`) that provides
   multiple root IDs and verifies that a single SVG is generated containing
   all expected nodes.
