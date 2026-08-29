# Coding and Testing Standards: family_graph

## Coding Standards

### Rules

1. **Line Length**: All lines should be no longer than 80 characters, unless
   strictly impossible.
2. **Whitespace**: No lines should end with one or more spaces (no trailing
   whitespace).

### Guidelines

1. Following the common convection for ruby code, method bodies should be,
as much as practical, small/short, employing "helper" routines for
lower-level work.
2. Try to avoid "\n\n" sequences within method bodies. Following 1. will
generally make this unnecessary.

## Testing Standards
3. **Exit Codes**: All executable test scripts MUST exit with a zero value
   for success and a non-zero value for failure.
