# family_graph Design and Requirements Specification

## Overview
`family_graph` is a clean-slate implementation of the genealogical tree 
visualization tool, written in Ruby. This project uses a recursive 
topological traversal that mirrors the structure of a family tree to generate 
accurate, human-verified family tree diagrams.

## Current Functional Requirements
- **Recursive Topological Traversal**: The engine traverses the family 
  tree from root nodes to descendants to calculate spatial layouts.
- **Support for Spousal Pairings**: Spouses are treated as atomic units, 
  placed adjacent to each other.
- **SVG Generation**: The layout is rendered into a scalable vector graphics 
  (SVG) format.
- **Configurable Edge Directionality**:
  - Ancestry: Arrows point from child to parent (default).
  - Descent: Arrows point from parent to child.
  - None: Lines without arrowheads.
- **CLI-based Generation**: A professional CLI tool (`main.rb`) supports:
  - Configuration of root IDs (multiple supported).
  - Automated root detection (parentless nodes).
  - Output directory configuration.
  - Abbreviated CLI flags for usability.
- **Data Robustness**: Handles missing data fields (e.g., missing parent 
  fields, birth/death dates) gracefully without crashing.

## Implemented Features Status
| Feature | Status |
| :--- | :--- |
| Topological Traversal | Implemented |
| SVG Output Rendering | Implemented |
| Configurable Directionality | Implemented |
| CLI Tool (`main.rb`) | Implemented |
| Automated Root Detection | Implemented |
| Support for Multiple Roots | Implemented |

## Class Structure
- **`Person`**: Domain model, manages relationships and dynamic fields.
- **`Coordinates`**: Repository for calculated node and spouse pair locations.
- **`Graph`**: Recursive layout engine that calculates all coordinates.
- **`GraphRenderer`**: Handles SVG XML generation, including markers and 
  formatting.
- **`DataLoader`**: Parses YAML into the object graph.
