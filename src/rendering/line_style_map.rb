require 'ruby_contracts'
require 'family_constants'

# Encapsulates mapping from relationship types to SVG line style
# attribute strings using a lookup hash.
module LineStyleMap
  include Contracts::DSL

  module_function

  STYLE_MAP = {
    SPOUSE     => 'stroke-dasharray="8, 4"',
    ADOPTIVE   => 'stroke-dasharray="0, 10" stroke-linecap="round"',
    ASSUMED    => 'stroke-dasharray="8, 4"',
    BIOLOGICAL => ''
  }.freeze

  # The SVG attribute string for the given relationship type.
  # @param type [String] Relationship type (e.g. SPOUSE, BIOLOGICAL,
  # ADOPTIVE, ASSUMED).
  # @return [String] SVG attribute string.
  pre :valid_type do |type| valid_relationship_types.include?(type) end
  def style_for(type)
    STYLE_MAP.fetch(type, '')
  end

  # Array: all valid relationship types
  def valid_relationship_types
    $relationship_types
  end

  private

  $relationship_types = STYLE_MAP.keys.freeze

end
