# family_graph Design Specification

## Overview
`family_graph` is a clean-slate implementation of the genealogical tree 
visualization tool, written in Ruby. This project uses a recursive 
topological traversal that mirrors the structure of a family tree to generate 
accurate, human-verified family tree diagrams.

## Class Structure
- **`Person`**: Domain model, manages relationships and dynamic fields.
- **`Coordinates`**: Global registry for node and spouse pair locations.
- **`LayoutContext`**: Orchestrates data access and coordinate registry.
- **`LayoutStep`**: Base command for the layout pipeline.
- **`GraphRenderer`**: Handles SVG XML generation, including markers and 
  formatting.
- **`DataLoader`**: Parses YAML into the object graph.

## Verification Strategy
To ensure the integrity of the layout pipeline, we utilize a two-tier 
verification approach for each step:

1. **Logical Correctness (YAML Oracle)**: 
   - A snapshot of the `Coordinates` registry (serialized as YAML) is captured 
     immediately after a `LayoutStep` completes.
   - This YAML serves as the "golden file" for functional testing.
   - Any layout logic change must maintain structural parity with this oracle.

2. **Visual Sanity (SVG Output)**: 
   - An SVG file is rendered as the final step of the pipeline.
   - A structural check ensures the file is created and falls within expected 
     size parameters.
   - This acts as a sanity check for rendering regressions.
