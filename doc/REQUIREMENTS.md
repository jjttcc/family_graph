# family_graph Requirements Specification (V2)

## Functional Requirements
- **Bi-directional Topological Traversal**: The engine supports recursive
  traversal for both descendant (Root -> Children) and ancestor (Leaf ->
  Parents) tree generation.
- **Support for Spousal Pairings and Multi-Spouse**: Spouses are treated as
  atomic units. Support for multiple spouses per person, with chronological
  ordering and visual indicators for multi-spouse individuals.
- **SVG Generation**: The layout is rendered into a scalable vector graphics
  (SVG) format.
- **Configurable Edge Directionality**:
  - Ancestry: Arrows point from child to parent.
  - Descendancy: Arrows point from parent to child.
  - None: Lines without arrowheads (Default).
- **CLI-based Generation**: A professional CLI tool (`main.rb`) supports:
  - Configuration of root IDs (multiple supported).
  - Automated root detection (parentless nodes).
  - Configurable traversal direction (ancestor/descendant).
  - Configurable arrowhead directionality.
  - Output directory configuration.
  - Abbreviated CLI flags for usability.
- **Data Robustness**: Handles missing data fields (e.g., missing parent 
  fields, birth/death dates) gracefully without crashing.

## Implemented Features Status
| Feature | Status |
| :--- | :--- |
| Topological Traversal (Bi-directional) | Implemented |
| SVG Output Rendering | Implemented |
| Configurable Edge Directionality | Implemented |
| CLI Tool (`main.rb`) | Implemented |
| Automated Root Detection | Implemented |
| Support for Multiple Roots | Implemented |
| Multiple Spouse Rendering Indicator | Implemented |
