# Incarnations Architectural Design

## Overview
The `Person` object will transition from holding a single (x, y) coordinate pair to managing a collection of `CoordinateSet` objects.

## CoordinateSet
A `CoordinateSet` is a simple data structure containing:
  - x, y coordinates.
  - `spouse_id`: The ID of the spouse this coordinate set is tied to, or `nil` if unbound (default context).

## Person Class Changes
- Add `@coordinate_sets = []` (or a similar structure).
- Add method `get_coordinate_set(spouse_id = nil)` to retrieve the correct set based on context.
- Add method `add_coordinate_set(x, y, spouse_id = nil)` to store new positions.

## Graph Renderer Impact
The renderer will need to be updated to pass the current rendering context (spouse_id) when requesting coordinates for a `Person` node.
