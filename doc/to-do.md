                          TO-DO LIST FOR FAMILY GRAPH
                        Sun Oct  4 07:36:37 AM EDT 2026

  o immediate:
    - Corrections/improvements to recent code changes by Gemini:
      * GraphRenderer.render:
        + coding standards: long lines; unneeded :respond_to? calls
        + reporting belongs in a reporting method or module.
        + retrun at beginning
      * Node descendants:
        + Implement 'width'.
    - oracle for testing:
      * for layout step1
  o Another set of ideas for dealing with crossing lines:
    - try different possibilities, combinations, experiments, algorithms, etc.
      and store each one; then choose the best one.
    - introduce randomness in the above.
    - employ "discovered" rules, such as:
      * line up full siblings in a row, next to each other
      * put half-siblings on the left or right side so that the line to
        their other parent doesn't cross those of their other
        half-siblings.
    - create at least 5 different "untangling" algorithms or methods:
      * test each one, as well as testing different combinations of them.
      * if an algorithm turns out to be not useful, discard it.
    - perform a manual session: working with Gemini, after employing some
      different experiments, combinations, etc. identify 1 to 3 "solutions"
      and inspect the results of each one by:
      * finding problems in a resulting diagram by visually inspecting it
        and attempting to manually fix each problem
      * each "fix" will be documented as a potential "algorithm" component.
      * for each "fix" that turns out to be codable, turn it into ruby code
        and add it as part of one or more of the "solutions"
      * consider employing these fixes [possibly also including other
        resolution components found to work in the work done previously] to
        come up with a new "solution".
  o New directory/cluster - analysis - holds:
    - node overlap detection logic
    - crossing lines detection logic
    - anything else that needs to be detected
  o Regarding the analysis:
    - what does the order need to be with respect to detecting crossed lines
      versus overlapping nodes?
    - if the answer is that each one interferes with the other:
      * do we just pick the order that works best?
      * do we execute these steps more than once - for example:
          + While the layout is not " perfect ":
            = Perform the Crossing Lines detection, and then fix it
            = Perform the overlapping nodes detection, and then fix it
            = Perform both Crossing Lines and overlapping nodes detection and
              if no problems are detected mark the layout as " perfect "
    - during an analysis/resolution phase do we need to perform the
      analysis/resolution more than once - for example:
        * While the problem, p [ either Crossing Lines or overlapping
          nodes] being addressed is not solved:
          + Run the analysis for 'p'
          + Change the layout to attempt to fix 'p'
          + Run the analysis for 'p' and if no problems with respect to 'p'
            are detected mark 'p' as solved
  o soon:
    - tests:
      * enhance "sample" dataset.
  o somewhat soon:
    - Incorporate gemini's python-script logic into family_graph to use for
      verification of integrity of the graph.
      * Use this to add a(some) layout pass(es) to improve the graph.
  o functionality/requirements:
    - fix/optimize crossing lines
    - ...
  o bugs:

COMPLETED:
    - When the program generates an svg file, it should also output a
      report:
      * # of nodes (<n1> persons, <n2> are duplicates)
      * # of crossed lines
    - Implement OverlapEliminationStep.
    - Make 'context' (LayoutContext) an attribute instead of method arg.
    - In WidthCalculatorStep, set_nodes_initialized to true when finished.
    - [X]Remove now-obsolete coordinate_sets abstraction from Person.
    - for a person with 2 spouses, draw that person twice, so that she/he
      can be placed next to both spouses.

