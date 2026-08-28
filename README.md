# family_graph

A genealogical tree visualization tool written in Ruby.

## Features
- Recursive topological traversal for accurate layouts.
- SVG generation for scalable diagrams.
- Configurable relationship directionality (Ancestry, Descent, None).
- CLI tool for automated graph generation.

## Installation
Ensure Ruby is installed, then install dependencies:
```bash
bundle install
```

## Usage
Generate a graph for a specific root node:
```bash
./src/main.rb -i john_frost_1680 -o ./output
```

List all root nodes:
```bash
./src/main.rb -r
```

For more options, run:
```bash
./src/main.rb -h
```
