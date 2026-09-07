# Bug: Node Overlaps in Layout

## Problem
In the latest SVG output, certain nodes are overlapping, with the edge of one node partially obscuring another. This indicates that the compaction logic (or the initial placement) is failing to maintain the minimum required spacing constraint (`NODE_WIDTH` + padding) between adjacent nodes on the same generation level.

## Status
- Reproduced visually in the latest SVG output.
- Needs investigation to determine if the issue is in the `CompactionLayoutStrategy` gap detection (threshold) or `InitialPlacementStrategy` placement logic.
