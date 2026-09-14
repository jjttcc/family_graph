# Project Architectural Overview: Genealogy Layout Pipeline

## 1. High-Level Architecture
The application is a command-line genealogical tree renderer. It follows a
modular pipeline architecture where raw YAML data is loaded, transformed
into a hierarchical tree, and then refined through sequential layout steps.

- **Orchestration**: `LayoutOrchestrator` manages the flow of data through
  the pipeline.
- **State Management**: `LayoutContext` serves as the centralized, atomic
  state manager for all coordinate and node-placement operations.
- **Pipeline Stages**:
  - `HierarchicalPlacementStep`: Assigns generations and initial `y`
    positions.
  - `StructuralAlignmentStep`: Reorders subtrees to minimize edge crossings.
  - `CompactionLayoutStep`: Shrinks the graph by moving subtrees to fill
    whitespace.

## 2. Detailed Code Design
- **Core Entities**: `Person` represents a node in the graph, containing
  genealogical data, spouses, and children. It uses `method_missing` for
  flexible YAML attribute access.
- **Hierarchy Analysis**: `HierarchyAnalyzer` recursively traverses parents
  (bottom-up) to calculate generations and uses a convergence loop in
  `align_spouses` to ensure generational stability across spousal chains.
- **Verification**: Uses a "Golden File" Oracle approach. The pipeline
  snapshots the `Coordinates` registry to YAML at critical stages.

## 3. Important Concepts for Future Gemini
- **Atomicity**: Any change to a person's `x` or `y` coordinates MUST pass
  through `LayoutContext#update_person` or `LayoutContext#shift_subtree` to
  ensure synchronization between the `Person` objects and the global
  `Coordinates` registry.
- **Rendering**: The `GraphRenderer` translates the `Coordinates` registry
  into the final SVG output.
- **Multi-Spouse Handling**: The current `Person` class supports multiple
  coordinate sets - one set per spouse; of the person has no spouses then
  one set total. However, the rendering engine still treats nodes as
  singular units. This is the primary area for architectural evolution.
- **Coding Standards**: All code must strictly adhere to the standards
  documented in: for_gemini/detailed_coding_guidelines
