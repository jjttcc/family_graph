# frozen_string_literal: true

# Renders a visual chart legend with line style samples and descriptions.
class Legend
  def initialize(line_styles, width:)
    @line_styles = line_styles
    @width       = width
    @item_height = 20
    @padding     = 30
    @box_width   = 280
  end

  def height
    @padding * 2 + @line_styles.size * @item_height
  end

  def render(start_y)
    svg = []
    svg << "<g id=\"legend\" transform=\"translate(#{@padding}, #{start_y})\">"
    svg << "<rect width=\"#{@box_width}\" height=\"#{height}\" fill=\"white\" stroke=\"#ccc\" rx=\"5\" ry=\"5\"/>"
    
    current_y = @padding + 10
    @line_styles.each do |_, style|
      svg << "<line x1=\"20\" y1=\"#{current_y}\" x2=\"70\" y2=\"#{current_y}\" stroke=\"black\" #{style.to_svg_attributes}/>"
      svg << "<text x=\"90\" y=\"#{current_y + 5}\" font-family=\"Arial\" font-size=\"12\">#{style.description}</text>"
      current_y += @item_height
    end
    
    svg << "</g>"
    svg.join("\n")
  end
end
