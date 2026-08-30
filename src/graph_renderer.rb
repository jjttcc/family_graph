require 'ruby_contracts'
require_relative 'family_constants'

# Renders the calculated genealogical coordinates into an SVG diagram.
class GraphRenderer
  include Contracts::DSL

  NODE_WIDTH = 120
  NODE_HEIGHT = 60
  FONT_SIZE_NAME = 9
  FONT_SIZE_DATE = 7

  public

  # Initialize renderer. Label mode: :dates, :ids, or :both.
  def initialize(coordinates, people, direction = :ancestry,
                 label_mode = :dates)
    @coordinates = coordinates
    @people = people
    @direction = direction
    @label_mode = label_mode
  end

  # Render SVG to specified directory.
  pre :valid_output_dir do |output_dir| Dir.exist?(output_dir) end
  def render(output_dir, root_id = "tree")
    nodes = @coordinates.nodes
    if nodes.empty? then
      puts "No nodes to render."
      return
    end
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    filename = "family_tree_#{root_id}_#{timestamp}.svg"
    output_path = File.join(output_dir, filename)
    offset_x, offset_y, width, height = calculate_dimensions(nodes)
    svg_lines = []
    render_spousal_lines(svg_lines, offset_x, offset_y)
    render_parent_child_lines(svg_lines, nodes, offset_x, offset_y)
    svg_nodes = []
    render_nodes(svg_nodes, nodes, offset_x, offset_y)
    svg_template = <<~SVG
      <svg width="#{width}" height="#{height}"
        xmlns="http://www.w3.org/2000/svg">
        <rect width="100%" height="100%" fill="white"/>
        <defs>
          <marker id="arrowhead" markerWidth="10" markerHeight="7"
                  refX="9" refY="3.5" orient="auto">
            <polygon points="0 0, 10 3.5, 0 7" />
          </marker>
        </defs>
      #{svg_lines.join("\n")}
      #{svg_nodes.join("\n")}
      </svg>
    SVG
    File.write(output_path, svg_template)
    puts "Successfully rendered SVG to #{output_path}"
  end

  private

  def calculate_dimensions(nodes)
    min_x = nodes.values.map { |coord| coord[0] }.min
    min_y = nodes.values.map { |coord| coord[1] }.min
    max_x = nodes.values.map { |coord| coord[0] }.max
    max_y = nodes.values.map { |coord| coord[1] }.max
    offset_x = -min_x + 50
    offset_y = -min_y + 50
    width = max_x - min_x + NODE_WIDTH + 100
    height = max_y - min_y + NODE_HEIGHT + 100
    [offset_x, offset_y, width, height]
  end

  def render_spousal_lines(svg_lines, offset_x, offset_y)
    @coordinates.couples.each do |spouse1_id, spouse2_id|
      if
        @coordinates.has_node?(spouse1_id) && @coordinates.has_node?(spouse2_id)
      then
        c1 = @coordinates.node(spouse1_id)
        c2 = @coordinates.node(spouse2_id)
        left_c, right_c = [c1, c2].sort_by { |c| c[0] }
        x1 = left_c[0] + NODE_WIDTH + offset_x
        y1 = left_c[1] + (NODE_HEIGHT / 2) + offset_y
        x2 = right_c[0] + offset_x
        y2 = right_c[1] + (NODE_HEIGHT / 2) + offset_y
        svg_lines << "  <line x1=\"#{x1}\" y1=\"#{y1}\" x2=\"#{x2}\" " \
                     "y2=\"#{y2}\" stroke=\"black\" stroke-width=\"1\" " \
                     "stroke-dasharray=\"4\" />"
      end
    end
  end

  def render_parent_child_lines(svg_lines, nodes, offset_x, offset_y)
    nodes.each do |id, (x, y)|
      person = @people[id]
      if person.nil? then next end
      person.parents.each do |parent|
        parent_id = parent.id
        if parent_id && @coordinates.has_node?(parent_id) then
          px, py = @coordinates.node(parent_id)
          if @direction == :descent then
            x1 = px + (NODE_WIDTH / 2) + offset_x
            y1 = py + NODE_HEIGHT + offset_y
            x2 = x + (NODE_WIDTH / 2) + offset_x
            y2 = y + offset_y
          else
            x1 = x + (NODE_WIDTH / 2) + offset_x
            y1 = y + offset_y
            x2 = px + (NODE_WIDTH / 2) + offset_x
            y2 = py + NODE_HEIGHT + offset_y
          end
          marker = (@direction == :none) ? "" : " marker-end=\"url(#arrowhead)\""
          svg_lines << "  <line x1=\"#{x1}\" y1=\"#{y1}\" x2=\"#{x2}\" " \
                       "y2=\"#{y2}\" stroke=\"black\"#{marker} />"
        end
      end
    end
  end

  def render_nodes(svg_nodes, nodes, offset_x, offset_y)
    nodes.each do |id, (x, y)|
      person = @people[id]
      if person.nil? then next end
      nx = x + offset_x
      ny = y + offset_y
      name_label = "#{person.given_name} #{person.surname}".strip
      if person.spouses.size > 1 then
        name_label += " +"
      end
      birth = person.respond_to?(:birth_date) ? person.birth_date : nil
      death = person.respond_to?(:death_date) ? person.death_date : nil
      b_str = (birth || "").to_s
      d_str = (death || "").to_s
      date_label = "#{b_str}, #{d_str}".gsub(/^, |, $/, "")
      texts = []
      texts << ["#{nx + NODE_WIDTH/2}", "#{ny + 15}", name_label, 9]
      case @label_mode
      when :dates then
        texts << ["#{nx + NODE_WIDTH/2}", "#{ny + 35}", date_label, 7]
      when :ids then
        texts << ["#{nx + NODE_WIDTH/2}", "#{ny + 35}", person.id, 7]
      when :both then
        texts << ["#{nx + NODE_WIDTH/2}", "#{ny + 30}", date_label, 7]
        texts << ["#{nx + NODE_WIDTH/2}", "#{ny + 42}", person.id, 7]
      end
      svg_nodes << "  <rect x=\"#{nx}\" y=\"#{ny}\" " \
                   "width=\"#{NODE_WIDTH}\" height=\"#{NODE_HEIGHT}\" " \
                   "fill=\"white\" stroke=\"black\" />"
      texts.each do |x_pos, y_pos, label, size|
        svg_nodes << "  <text x=\"#{x_pos}\" y=\"#{y_pos}\" " \
                     "font-family=\"Arial\" font-size=\"#{size}\" " \
                     "text-anchor=\"middle\">#{label}</text>"
      end
    end
  end

end
