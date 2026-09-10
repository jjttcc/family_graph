# Incarnations Functionality Requirements

1.  **Multi-Spouse Support**: A person with multiple spouses shall be rendered as multiple incarnations (node duplications) to allow for clean branching.
2.  **Coordinate Sets**: Each `Person` object must manage a collection of `CoordinateSets`.
3.  **Binding**: Each `CoordinateSet` must be bindable to a specific `spouse_id` (representing the marriage context) or be unbound (`nil` for single/default context).
4.  **Default Context**: Every `Person` shall have at least one unbound `CoordinateSet` (default context) to ensure single persons or primary node positions are always represented.
