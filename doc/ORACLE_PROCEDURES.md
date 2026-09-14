# Oracle Procedures: family_graph

This document outlines the standard operating procedures for managing
"Oracle" (Golden File) YAML snapshots used to verify the layout pipeline.

## 1. Creating and Promoting a New Oracle
Follow this procedure to generate a new Oracle after significant logic
changes or when introducing a new test dataset.

1.  **Prepare Input**: Ensure your input YAML file exists in `data/`.
2.  **Run Pipeline**: Execute the pipeline up to the target stage:
    `./bin/family_graph -m ids data/<input_file>.yaml -s <stage_number>`
    (This generates a candidate file in `test/candidates/`).
3.  **Visual Verification**: Open the generated SVG in `/tmp/test_dir/` and
    visually verify that the layout is correct and structurally sound.
4.  **Promote to Oracle**: If verified, promote the candidate to the Oracle
    directory: `mv test/candidates/<candidate_file>.yaml
    data/oracles/<data_basename>_stage_<N>_oracle.yaml` `chmod 444
    data/oracles/<data_basename>_stage_<N>_oracle.yaml`

## 2. Automated Regression Testing
Use this procedure to verify that existing Oracles remain consistent with
the current code.

5.  **Run Verification Script**: Execute the verification script for the
    target stage: `ruby spec/verify_stage_<N>_oracle.rb`
6.  **Interpret Results**:
    - **Success**: The candidate matches the Oracle exactly.
    - **Failure**: The pipeline output has drifted. The script will exit non-
      zero. Inspect the diff between `data/oracles/<oracle>.yaml` and
      `test/candidates/<candidate>.yaml` to identify the deviation.

## 3. Upgrading/Adapting Oracles
Use this procedure when intentional layout changes occur (e.g., compaction
logic updates) or when adapting an Oracle to a new, larger dataset.

1.  **Generate New Candidate**: Run the pipeline as in Section 1.
2.  **Compare (Diff)**: Perform a structural diff between the old Oracle and
    the new candidate. `diff data/oracles/<old_oracle>.yaml
    test/candidates/<new_candidate>.yaml`
3.  **Analyze**: Determine if the diff represents an *intended*
    improvement (e.g., tighter compaction) or an *unintended* regression
    (e.g., node overlap).
4.  **Accept Changes**: If the diff is intended, promote the new candidate
    to overwrite the old Oracle using the procedure in Section 1.
