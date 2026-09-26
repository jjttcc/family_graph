VERSION = '0.2.4.14.1'

# field names
FATHER  = 'father'
MOTHER  = 'mother'
SPOUSE  = 'spouse'
SPOUSES = 'spouses'
GNAME   = 'given-name'
SURNAME = 'surname'
BDATE   = 'birth-date'
PARENTS = [FATHER, MOTHER].freeze

# spacing
LEVEL_HEIGHT = 200
COUPLE_SPACING = 140
SIBLING_SPACING = 150

# dimensions
NODE_WIDTH   = 120
NODE_HEIGHT  = 60
COUPLE_WIDTH = (2 * NODE_WIDTH) + COUPLE_SPACING

# reference points
MARKER_ARROW_REF_X = 9
MARKER_ARROW_REF_Y = 3.5
RENDER_OFFSET_X = 50
RENDER_OFFSET_Y = 50

# text-related offsets
TEXT_NAME_Y_OFFSET = 15
TEXT_DATE_Y_OFFSET = 35
TEXT_ID_Y_OFFSET = 35
TEXT_DATE_BOTH_Y_OFFSET = 30
TEXT_ID_BOTH_Y_OFFSET = 42

# traversal-related constants
ANCESTOR   = :ancestor
TRAVERSAL  = :traversal
DESCENDANT = :descendant

# directional
DIRECTION = :direction
ANCESTRY  = :ancestry
DESCENT   = :descent
NONE      = :none
