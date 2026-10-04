# Experiment 1 Results: Stochastic Perturbation and Simulated Annealing
<!-- Author: Gemini -->

## Overview
Experiment 1 explored non-deterministic, probabilistic search strategies to
optimize family graph line crossings and node orderings. The core
hypotheses tested were whether introducing stochastic sibling permutations,
multi-start trials, and simulated annealing with Boltzmann acceptance
probabilities could effectively navigate complex layout state spaces and
escape local minima.

---

## Experimental Implementation
1. **Stochastic Sibling Reordering (`StochasticSiblingReorderResolution`):**
   - Extended standard sibling reordering by introducing randomized
     permutation strategies (reversals, full shuffles, and circular
     rotations) for parent sibling groups involved in crossing pairs.
2. **Multi-Start Trial Runner (`ExperimentRunner`):**
   - Executed randomized multi-start trials across test YAML trees
     (`sample_tree_line_crossing.yaml`) with seeded random number
     generators.
3. **Simulated Annealing Optimizer (`SimulatedAnnealingOptimizer`):**
   - Implemented a cooling schedule ($T_{init} = 50.0$, cooling rate =
     $0.90$) combined with `LineCrossingAnalysis` fitness evaluations.
     Uphill moves (transitions increasing crossing counts) were
     conditionally accepted using Boltzmann probability $\exp(-\Delta C /
     T)$ to traverse layout barriers.

---

## Results & Findings
- **Baseline Efficiency:** Standard hierarchical placement
  (`HierarchicalPlacementStep`) combined with core layout heuristics already
  achieved 0 line crossings on standard sample trees
  (`sample_tree_line_crossing.yaml`) and complex family trees
  (`master_tree.yaml`).
- **Stochastic Search Behavior:** When evaluated on graphs containing
  initial crossing geometries, stochastic multi-start trials successfully
  explored varied permutations. However, because tree hierarchical depth and
  sibling spacing are tightly coupled to topological parent-child
  constraints, purely random shuffles often increased crossing counts rather
  than reducing them, highlighting the need for structurally guided moves.
- **Simulated Annealing Performance:** The simulated annealing framework
  proved stable, correctly maintaining historical best coordinate states via
  `Marshal` snapshotting and rolling back failed trial steps. It
  demonstrated robust convergence behavior without regressions.

---

## Conclusions
Experiment 1 validated that probabilistic meta-heuristics (Simulated
Annealing and stochastic perturbation) can be safely wrapped around layout
coordinate states with robust rollback mechanisms. However, random shuffling
alone is inefficient for highly structured genealogical hierarchies.
Experiment 2 will pivot to a radically different paradigm.
