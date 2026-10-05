# Module for generating raw SVG XML elements.
module SVGUtility

  private

  def rect(x, y, width, height, stroke = 'black', fill = 'white')
    "  <rect x=\"#{x}\" y=\"#{y}\" width=\"#{width}\" " \
    "height=\"#{height}\" fill=\"#{fill}\" stroke=\"#{stroke}\" />"
  end

  def line(x1, y1, x2, y2, stroke = 'black', stroke_width = 1,
           dash = nil, marker = nil, linecap = nil)
    attr = "stroke=\"#{stroke}\" stroke-width=\"#{stroke_width}\""
    if dash then
      dash_attr = " stroke-dasharray=\"#{dash}\""
    else
      dash_attr = ""
    end
    if linecap then
      linecap_attr = " stroke-linecap=\"#{linecap}\""
    else
      linecap_attr = ""
    end
    if marker then
      marker_attr = " marker-end=\"url(#arrowhead)\""
    else
      marker_attr = ""
    end
    attr += dash_attr + linecap_attr + marker_attr
    "  <line x1=\"#{x1}\" y1=\"#{y1}\" x2=\"#{x2}\" y2=\"#{y2}\" #{attr} />"
  end

  def text(x, y, label, size, anchor = 'middle')
    "  <text x=\"#{x}\" y=\"#{y}\" font-family=\"Arial\" " \
    "font-size=\"#{size}\" text-anchor=\"#{anchor}\">#{label}</text>"
  end

  def template(width, height, lines, nodes)
    <<~SVG
      <svg width=\"#{width}\" height=\"#{height}\"
        xmlns=\"http://www.w3.org/2000/svg\">
        <rect width=\"100%\" height=\"100%\" fill=\"white\"/>
        <defs>
          <marker id=\"arrowhead\" markerWidth=\"10\" markerHeight=\"7\"
                  refX=\"#{MARKER_ARROW_REF_X}\"
                  refY=\"#{MARKER_ARROW_REF_Y}\" orient=\"auto\">
            <polygon points=\"0 0, 10 3.5, 0 7\" />
          </marker>
        </defs>
      #{lines.join("\n")}
      #{nodes.join("\n")}
      </svg>
    SVG
  end

end
