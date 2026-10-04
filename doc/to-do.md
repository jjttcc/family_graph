# TO-DO LIST FOR FAMILY GRAPH
## Sun Oct  4 07:36:37 AM EDT 2026
  - immediate:
    - oracle for testing:
      - [X]for layout step1
      - for layout step2
      - for layout step3
  - somewhat soon:
    - layout improvements:
      - In many cases, space between two nodes/couples that are next to
        each other, are larger than necessary - decrease a bit.
        Note: A positive side-effect of this could (should) be, in some
        cases, that children are more aligned, horizontally, with their
        parents.
      - Adjust some positionings of child vs parent such that child is
        closer to parent on the x axis - do this "manually", with gemini,
        recording what is being done in order to, if possible, automate
        these "placement improvements" in the code (probably with respect
        to line-crossing re-positioning).
      - In addition to father/mother, accommodate adoptive-father,
        assumed-father, adoptive-mother, assumed-mother. Consider using a
        dotted (or similar, but different from spousal dashed lines) from
        child to assumed/adoptive f/m. SVG can easily accommodate different
        styles of line for each type of "parent".
    - Create a graph_primitives directory and move each class in
      graph_primitives.rb into its own file - put in the graph_primitives
      directory.
  - possibilities for later:
    - embed text (such as the contents of the 'notes' [and other] fields)
      using <svg> or similar tag.
  - functionality/requirements:
  - bugs:

# COMPLETED
  - bugs:
    - in rendering of master_tree.haml, the following couples are scrambled[1]:
      - edward_frost_1723, jane_baker_1742
      - john_westcott_1756, mary_salter_1756

# NOTES
[1] Lined up in the same row, but out of order
