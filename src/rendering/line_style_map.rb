require 'family_constants'

# Encapsulates mapping from parent relationship types to SVG line styling
# properties (stroke-dasharray, stroke-linecap, stroke-width, etc.).
class LineStyleMap

  public

  # Returns a hash of SVG line attributes for the given parent.
  # @param parent [Parent, nil] The parent object.
  # @return [Hash] SVG attributes hash.
  def self.style_for(parent)
    result = {
      stroke_dasharray: nil,
      stroke_linecap: nil,
      stroke_width: 1,
      stroke_color: 'black'
    }

    if parent != nil then
      if parent.type == ADOPTIVE then
        result[:stroke_dasharray] = '1, 4'
        result[:stroke_linecap] = 'round'
      elsif parent.type == ASSUMED then
        result[:stroke_dasharray] = '8, 4'
      else
        # Biological or default
      end
    end

    result
  end

  # Returns the dasharray string for the given parent.
  def self.dasharray_for(parent)
    style = style_for(parent)
    style[:stroke_dasharray]
  end

  # Returns the linecap string for the given parent.
  def self.linecap_for(parent)
    style = style_for(parent)
    style[:stroke_linecap]
  end

end
