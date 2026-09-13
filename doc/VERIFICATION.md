# Verification Strategy: Staged Oracle Pipeline

To ensure the integrity of the layout pipeline as we decouple it from the
legacy `Graph` class, we utilize a **Staged Oracle Verification** approach.

## Overview
Instead of verifying the entire pipeline at once, we verify incrementally
after each `LayoutStep`. This isolates bugs and ensures that the topological
layout, structural alignment, and compaction logic are verified
independently.

## The Verification Stages

| Stage | Pipeline Steps | Purpose |
| :--- | :--- | :--- |
| **Stage 1** | `HierarchicalPlacementStep` | Verify raw topological layout (generation alignment). |
| **Stage 2** | Stage 1 + `StructuralAlignmentStep` | Verify spousal adjacency and parental centering. |
| **Stage 3** | Stage 2 + `CompactionLayoutStep` | Verify overlap resolution and tree compactness. |

## The Oracle Mechanism (Per Stage)

Each stage produces a two-tier oracle for verification:

1.  **Logical Oracle (YAML Snapshot)**:
    - After the step executes, a snapshot of the `LayoutContext#coordinates`
      registry is serialized to YAML.
    - This YAML file becomes the "golden file" for future automated
      regression testing (via `diff`).

2.  **Visual Sanity Check (SVG)**:
    - An SVG is rendered from the snapshot.
    - A human performs a sanity check against defined visual criteria to
      approve the YAML snapshot.

## Workflow

1.  **Inject**: Insert `YamlOracleStep` into the pipeline after the stage
    being verified.
2.  **Execute**: Run the pipeline to produce `oracle_stage_N.yaml` and
    `snapshot_N.svg`.
3.  **Review**: Perform human sanity check on the SVG against stage-
    specific criteria.
4.  **Approve**: If the SVG is correct, commit the `oracle_stage_N.yaml` as
    the official golden file.
5.  **Regress**: Subsequent changes to the layout step must not change the
    YAML oracle output.
