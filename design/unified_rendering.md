# Design Proposal: Unified Multi-Root Rendering

## Overview
Currently, the `family_graph` tool renders a separate SVG diagram for
each root node ID provided. This design proposal outlines the steps to
unify multiple root IDs into a single, cohesive family tree diagram (one
SVG file).

## Architectural Changes

### 1. Refactor `Graph` Class (`src/graph.rb`)
- **Constructor Update**: Modify `Graph#initialize` to accept a collection
  of root `Person` objects instead of a single root.
- **Initialization Logic**: Update the constructor to iterate over the
  provided collection and call `add_coords` for each person sequentially.
  The existing coordinate placement logic (using `@next_x` to manage
  horizontal spacing) should inherently position multiple root trees side-by-
  side without overlap.

### 2. Refactor `main.rb`
- **Logic Encapsulation**: Refactor the procedural logic in `main.rb` into
  one or more dedicated driver/orchestrator classes (e.g.,
  `RenderingOrchestrator`).
- **Orchestration**: The `RenderingOrchestrator` will handle:
  - Loading data.
  - Determining the roots to be rendered.
  - Preparing the graph object (with the unified list of roots).
  - Invoking the `GraphRenderer`.

## Benefits
- **Improved Visualization**: Users can generate a single,
  comprehensive diagram representing multiple root connections if they
  exist in the dataset.
- **Code Maintainability**: Moving the orchestration logic out of `main.rb`
  improves separation of concerns and facilitates testing and future
  enhancements.
