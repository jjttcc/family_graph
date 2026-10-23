VERSION = '0.2.5.0.1'

# field names used in YAML data parsing and domain models
FATHER           = 'father'
MOTHER           = 'mother'
SPOUSE           = 'spouse'
SPOUSES          = 'spouses'
GNAME            = 'given-name'
SURNAME          = 'surname'
BDATE            = 'birth-date'
ADOPTIVE_FATHER  = 'adoptive-father'
ASSUMED_FATHER   = 'assumed-father'
ADOPTIVE_MOTHER  = 'adoptive-mother'
ASSUMED_MOTHER   = 'assumed-mother'
OTHER_NAMES      = 'other-names'
PARENTS = [FATHER, MOTHER].freeze

# parent (mother or father) relationship types
ADOPTIVE    = 'adoptive'
ASSUMED     = 'assumed'
BIOLOGICAL  = 'biological'

# layout spacing constants (in pixels)
LEVEL_HEIGHT = 200    # Vertical height interval between generations
COUPLE_SPACING = 60   # Horizontal separation gap between adjacent couple nodes
SIBLING_SPACING = 70  # Horizontal separation gap between adjacent sibling nodes
# Horizontal separation gap between partner A and partner B in a couple:
PARTNER_SPACING = 20

# node dimension constants (in pixels)
NODE_WIDTH   = 120    # Standard width of an individual person-node box
NODE_HEIGHT  = 60     # Standard height of an individual person-node box
# Total width of a couple-node (two persons plus spacing):
COUPLE_WIDTH = (2 * NODE_WIDTH) + COUPLE_SPACING

# SVG rendering reference points and offsets (in pixels)
MARKER_ARROW_REF_X = 9
MARKER_ARROW_REF_Y = 3.5
RENDER_OFFSET_X = 50
RENDER_OFFSET_Y = 50

# text-related Y coordinate offsets within rendered node boxes (in pixels)
TEXT_NAME_Y_OFFSET = 15
TEXT_DATE_Y_OFFSET = 35
TEXT_ID_Y_OFFSET = 35
TEXT_DATE_BOTH_Y_OFFSET = 30
TEXT_ID_BOTH_Y_OFFSET = 42

# graph traversal direction constants
ANCESTOR   = :ancestor
TRAVERSAL  = :traversal
DESCENDANT = :descendant

# diagram directional rendering modes
DIRECTION = :direction
ANCESTRY  = :ancestry
DESCENT   = :descent
NONE      = :none

# layout options configuration keys
LABEL_MODE       = :label_mode
OUTPUT_DIR       = :output_dir
STOP_AT_STAGE    = :stop_at_stage
LIST_ALL         = :list_all
LIST_ROOTS       = :list_roots

# operational mode and filtering keys
DATES      = :dates
ROOT_IDS   = :root_ids

# Missing data protocol sentinel value
DATA_NOT_AVAILABLE = :data_not_available
