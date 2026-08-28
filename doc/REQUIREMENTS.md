# family_graph Requirements Specification

## Functional Requirements
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
