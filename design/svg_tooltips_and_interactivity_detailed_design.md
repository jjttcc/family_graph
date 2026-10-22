# Detailed Design: SVG Tooltips and Interactive Inspect Details

## 1. Overview & Architectural Goals
This document provides the detailed technical design for adding hover
tooltips (Phase 1) and interactive click/inspect details (Phase 2) to family
tree SVG diagrams.

The design adheres to the following core principles:
- **Encapsulation**: All XML generation, attribute formatting, and metadata
  rendering are isolated within SVG-oriented helper classes
  (`SvgTooltip`, `SVGUtility`).
- **Forward Compatibility**: Node groups (`<g>`) emit both native `<title>`
  tags (for instant hover tooltips) and comprehensive `data-*` attributes
  (to support future click modals/sidebars without requiring re-rendering or
  changing node structures).
- **Adherence to Coding Standards**: Eiffel-style naming, 80-character line
  limit, explicit contracts (`Contracts::DSL`), public/private section
  grouping, and `if condition then ... end` formatting.
---

## 2. Data Extraction & Formatting (`SvgTooltip`)
The `SvgTooltip` module/class extracts biographical and relational
attributes from `PersonNode` and `CoupleNode` instances and formats them
into clean strings.

### PersonNode Tooltip & Metadata Schema
- **Display Name**: Full name (`given-name` + `surname`).
- **Dates**: Birth date and death date (formatted per `label_mode`).
- **Notes**: Any associated note string (e.g., `"Root ancestor."`).
- **Relationships**:
  - Parents (father/mother).
  - Spouses.
  - Children.

### CoupleNode Tooltip & Metadata Schema
- **Partner A & Partner B Names**.
- **Partnership Dates / Marriage Info** (if available).
- **Shared Children**.

---

## 3. SVG Element Markup Design

### Phase 1: Hover Tooltip (`<title>`)
Every rendered node group (`<g>`) will contain a `<title>` element as its
first child. When a user hovers over any part of the node box, the browser
natively displays this text.

**Example Markup (`PersonNode`):**
```xml
<g id="node_root_ancestor_100"
   data-person-id="root_ancestor_100"
   data-given-name="Alice"
   data-surname="Doe"
   data-birth="1850-01-01"
   data-death="1930-05-15"
   data-note="Root ancestor.">
  <title>Alice Doe (1850-01-01 - 1930-05-15)
Note: Root ancestor.</title>
  <rect x="0" y="0" width="120" height="60" fill="..." stroke="..."/>
  <text x="60" y="15" ...>Alice Doe</text>
  ...
</g>
```

### Phase 2: Interactive Click/Inspect Details (Future Readiness)
To support future click-to-inspect modals or sidebars in the browser without
modifying SVG rendering structures later, the `<g>` element will be
decorated with comprehensive `data-*` attributes:
- `data-person-id`
- `data-full-name`
- `data-birth-date`
- `data-death-date`
- `data-notes`
- `data-spouses`
- `data-children`

---

## 4. Component Interactions & Flow
1. **`GraphRenderer`**: Delegates node rendering to `SVGUtility`.
2. **`SVGUtility`**:
   - Calls `SvgTooltip.build_title(node)` to generate the
     `<title>` text.
   - Calls `SvgTooltip.build_data_attributes(node)` to generate XML
     attributes for the `<g>` element.
3. **Browser / SVG Viewer**:
   - Native hover rendering via `<title>`.
   - Future JavaScript event delegation listening for clicks on `<g>`
     elements, reading `data-*` attributes, and populating an overlay modal
     or inspector panel.
---

## 5. Verification & Testing Strategy
- **XML Validity**: Ensure generated SVGs pass `spec/test_svg_validity.rb`.
- **Structural Integrity**: Ensure `spec/test_svg_structural_integrity.rb`
  confirms correct element hierarchies (`<g>` containing `<title>` and
  `<rect>`).
