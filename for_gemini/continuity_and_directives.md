# Continuity & Directives Handbook for Future Gemini Instances

This handbook provides critical operational guidelines, project memory, and
architectural principles to ensure seamless continuity across Gemini
process restarts.

## Core Mandates & Continuity Protocol
- **Amnesia Prevention**: Upon startup or session resumption, always inspect
  recent logs (`logs/dialogue_log.md`), active status reports
  (`for_gemini/active_status_report.md`), and detailed coding guidelines
  (`for_gemini/detailed_coding_guidelines.md`).
- **Dialogue Logging (`lg`)**: Maintain a running log of all major actions,
  architectural decisions, and changes by appending status updates to
  `logs/dialogue_log.md`. Read this file when you first start up, and when
  writing to the file, maintain the format established by the past entries
  in the file.
  IMPORTANT: Make sure to append to the file - Don't overwrite it.
- **alias File**: The file for_gemini/alias is a list of "aliases" for
  Gemini. Read this file and commit it to memory. If you don't understand
  something in that file, ask "the user" to clarify.
- **Validation Discipline**: Never treat tests blindly, but ensure 100% test
  pass rate across `spec/master_test.rb`. Empirical verification via
  automated test suites is mandatory for all changes.  "Never treat tests
  blindly" means that even if an entire test suite executes with no
  failures, this doesn't prove that the code is correct or that it runs
  true to all documented, or implied, requirements. In other words, even if
  all tests pass, there may still be significant work to do.

## Architectural Principles (Node-Centric Refactoring)
- **Node-Centric Architecture**: The family tree graph layout pipeline
  operates exclusively on geometric primitives (`PersonNode`,
  `CoupleNode`, and `Node`) managed within `Coordinates`, rather than
  domain `Person` models.
- **Root Resolution**: [valid as of: Mon Oct 19 11:43:06 AM EDT 2026] Use
  `DomainTools.roots(people, options)` as the single source of truth for
  root determination, and `coords.root_nodes` for geometric root node
  inspection.
- **Offspring & Child Queries**: [valid as of: Mon Oct 19 11:43:06 AM EDT 2026]
  Use `coords.child_nodes_for(node)` to retrieve child `Node` instances
  (both singletons and couple nodes).
- **Width Calculation**: [valid as of: Mon Oct 19 11:43:06 AM EDT 2026]
  `WidthCalculatorStep` calculates offspring widths based on
  `coords.child_nodes_for(node)` to ensure absolute alignment with
  `HierarchicalPlacementStep`.

## Coding Standards & Conventions
Read and follow the rules and guidelines in:
for_gemini/detailed_coding_guidelines.md
