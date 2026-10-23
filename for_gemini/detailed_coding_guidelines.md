# Detailed Coding Standards
<!-- # vim: ts=2 sw=2 expandtab -->


This document captures the standards to be maintained in the
`family_graph` codebase.

## Rules

### General

- **Naming (Eiffel-Style)**: Query methods MUST NOT have `get_` prefixes
  (e.g., `id`, not `get_id`; `coordinate_set`, not `get_coordinate_set`).
- **Interface Segregation**: Do not implement empty stub methods.
- **Data Privacy**: Never include real PII in project files. Use safe,
  anonymous fixtures for testing.
- **Contract Enforcement**: Utilize `Contracts::DSL` (`pre`, `post`,
  `invariant`) for explicit design-by-contract enforcement.
- **Line Length**: All lines MUST be no longer than 80 characters.
- **Whitespace**: Do not leave trailing whitespace on lines.
- **Conditional Formatting**: Use `if x then y end` instead of `y if x`.
  And instead of:
    if x
      <statement>
    end
  use:
    if x then
      <statement>
    end
- **Class Documentation**: Every class MUST have a description comment.
- **Testing Exit Codes**: Executable test scripts MUST exit with 0 for
  success and non-zero for failure.
- **Formatting**: Keep code clean and consistently indented.
- **Iteration**: For iterating over keyed data structures, such as Hash,
  avoid using unneeded block parameters. For example, use `.each_value`
  for hash iteration when the key is not needed, instead of `each |_, value|`.
- **Flow Control**: Avoid mid-method returns. Structure methods to have
  a single exit point or clear, sequential flow.

### Methods

- **Functions**:
  - Methods that are functions that return a value should be
    named with a noun. For example, `position` instead of `get_position`; or
    `formatted_data` instead of `format_data`.
  - Functions should use the variable name `result` for the value/object
    to be returned. For example:
    ```ruby
    def func(arg)
      result = arg + processed(arg)
      if result.nil? then
        result = ""
      end
      result
    end
    ```
- **Procedures**: Methods that are procedures should be named to indicate
  that they are performing an action that causes a state change - typically
  by naming the procedure as a verb.

### Classes

- **public/private**: All method or attribute definitions should be within
  a 'public', 'private', or 'protected' section.

## Guidelines

### 1. API Design
- **Commands**: Explicitly name methods that perform state changes.
- **Precision**: Identifiers should be descriptive, full words. Avoid
  cryptic abbreviations.

### 2. Code Structure
- **Method Size**: Method bodies should be small, employing helper
  routines for lower-level work.
- **DRY (Don't Repeat Yourself)**: Extract shared logic into helper
  methods. Merge identical implementations.
- **Logical Grouping**: Use `public ### [Group Name]` and `private ###
  [Group Name]` headers to structure class sections.
- Avoid `\n\n` in methods.
- **Orchestration**: `main.rb` must remain a thin entry point.
  Orchestration logic belongs in `GraphOrchestrator` or equivalent.

### 3. Documentation & Comments
- **Method Comments**: Except in cases in which a method is simple and
  whose purpose is obvious, every method should have a description comment
  above the method name. If the method has `pre` or `post` conditions,
  the description must precede them.
- **Intent**: Comments must explain the *intent* (the "why"), not the
  mechanics (the "how").
- **Style**: Use full, grammatical sentences.

### 4. Testing
- **Flexibility**: Tests should be data-driven (e.g., counting nodes
  based on YAML input rather than hardcoding values).
- **Integrity**: Verify structural integrity (e.g., checking for line
  counts in SVG) to ensure diagram completeness.

### 5. Aesthetics
- **Readability**: Avoid dense logic. Break complex calculations into
  smaller, named, well-documented methods.

