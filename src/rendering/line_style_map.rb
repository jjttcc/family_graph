require 'family_constants'

# Encapsulates mapping from relationship types to SVG line style
# attribute strings using a lookup hash.
class LineStyleMap

  public

  STYLE_MAP = {
    SPOUSE     => 'stroke-dasharray="8, 4"',
    ADOPTIVE   => 'stroke-dasharray="1, 4" stroke-linecap="round"',
    ASSUMED    => 'stroke-dasharray="8, 4"',
    BIOLOGICAL => ''
  }.freeze

  # Returns the SVG attribute string for the given relationship type.
  # @param type [String] Relationship type (e.g. SPOUSE, BIOLOGICAL,
  # ADOPTIVE, ASSUMED).
  # @return [String] SVG attribute string.
  def self.style_for(type)
    STYLE_MAP.fetch(type, '')
  end

end
