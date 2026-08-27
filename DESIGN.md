# family_graph Design Specification

## Overview
`family_graph` is a clean-slate implementation of the genealogical tree
visualization tool, written in Ruby. This project abandons previous
heuristic layout attempts in favor of a **recursive, topological traversal**
that mirrors the structure of a family tree.

## Core Architectural Philosophy
- **Object-Oriented Design:** The system is modeled directly after the
  domain entities (`Person`, `Couple`, `Branch`) rather than being a
  procedural algorithm applied to raw data.
- **Recursive Branching:** A `FamilyBranch` encapsulates a root (a `Person`
  or a `Couple`) and all its child branches. The layout is calculated
  recursively.
- **Topological Integrity:** Connections define structure. We traverse the
  tree branch-by-branch, ensuring parent-child and spouse relationships are
  preserved spatially.

## Class Structure

### 1. Domain Entities
- **`Person`**: Represents an individual. Holds raw data: ID, given name,
  surname, birth/death dates.
- **`Couple`**: Encapsulates two `Person` objects (spouses). It is an atomic
  rendering unit. It knows how to calculate its own width and the midpoint
  for anchoring its children.

### 2. Recursive Structure
- **`FamilyBranch`**: The recursive heart of the system.
  - Represents a union (either a single `Person` or a `Couple`) and a
    collection of `sub_branches` (children).
  - **`calculate_width`**: Recursively calculates the total width required
    for this branch and all its descendants.
  - **`assign_coords(x, y)`**: Recursively assigns `(x, y)` coordinates to
    all nodes in the branch, ensuring proper spacing and centering.

### 3. Coordinator
- **`GraphRenderer`**: The top-level entry point.
  - Loads the YAML data.
  - Assembles the structure into `FamilyBranch` objects.
  - Triggers the recursive width calculation and coordinate assignment.
  - Handles the final generation of the SVG output.

## Rationale
This OO model achieves three primary goals that previous attempts failed:
1.  **Encapsulation:** The `FamilyBranch` class handles the recursive math,
    keeping rendering logic clean and decoupled from the graph structure.
2.  **Readability:** The code will read like a description of a family tree,
    making it easy to understand and debug.
3.  **Maintainability:** By treating couples and branches as objects, we
    can modify layout rules (like spouse spacing or child centering) by
    updating a single class, rather than chasing coordinate drift across
    the entire engine.
