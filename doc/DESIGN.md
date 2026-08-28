# family_graph Design Specification

## Overview
`family_graph` is a clean-slate implementation of the genealogical tree 
visualization tool, written in Ruby. This project uses a recursive 
topological traversal that mirrors the structure of a family tree to generate 
accurate, human-verified family tree diagrams.

## Class Structure
- **`Person`**: Domain model, manages relationships and dynamic fields.
- **`Coordinates`**: Repository for calculated node and spouse pair locations.
- **`Graph`**: Recursive layout engine that calculates all coordinates.
- **`GraphRenderer`**: Handles SVG XML generation, including markers and 
  formatting.
- **`DataLoader`**: Parses YAML into the object graph.
