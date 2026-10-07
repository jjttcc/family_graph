require 'ruby_contracts'
require 'family_constants'
require_relative 'line_style'

# Encapsulates mapping from relationship types to LineStyle instances.
module LineStyleMap
  include Contracts::DSL

  module_function

  STYLE_MAP = {
    SPOUSE     => LineStyle.new(stroke_width: 2, dash_array: '4, 2',
                                description: 'Spouse'),
    ADOPTIVE   => LineStyle.new(stroke_width: 3, dash_array: '0, 10',
                                stroke_linecap: 'round',
                                description: 'Adoptive Parent'),
    ASSUMED    => LineStyle.new(stroke_width: 1, dash_array: '8, 4',
                                description: 'Assumed / Foster Parent'),
    BIOLOGICAL => LineStyle.new(stroke_width: 1,
                                description: 'Biological Parent')
  }.freeze

  # The LineStyle instance for the given relationship type.
  # @param type [String] Relationship type (e.g. SPOUSE, BIOLOGICAL,
  # ADOPTIVE, ASSUMED).
  # @return [LineStyle] LineStyle instance.
  pre :valid_type do |type| valid_relationship_types.include?(type) end
  def style_for(type)
    STYLE_MAP.fetch(type, LineStyle.new(stroke_width: 1, description: ''))
  end

  # Array: all valid relationship types
  def valid_relationship_types
    $relationship_types
  end

  private

  $relationship_types = STYLE_MAP.keys.freeze

end
