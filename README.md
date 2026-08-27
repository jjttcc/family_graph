# family_graph (Ruby Engine)

## Purpose
The `family_graph` engine is a clean-slate implementation of the
genealogical tree visualization tool, written exclusively in Ruby.

## Architectural Philosophy
- **Recursive Traversal:** The core engine uses a recursive, topological
  traversal (starting from root couples) to maintain branch connectivity and
  parent-child-spouse relationships.
- **Topological Integrity:** Rather than generation-based sorting,
  coordinates are calculated based on family branch topology to eliminate
  "drift" and ensure consistent alignment.
- **Couple-Centric:** Couples are rendered as atomic units, with children
  anchored to the midpoint of the couple's union.

## Requirements
1. **Spouse Adjacency:** Spouses must be rendered as a single unit with a
   defined separation.
2. **Spouse Connections:** A dotted line connects spouses programmatically.
3. **Child Alignment:** Children must be centered beneath the midpoint of
   their parents' union.
