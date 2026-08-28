require 'ruby_contracts'
require_relative 'family_constants'

# Renders the calculated genealogical coordinates into an SVG diagram.
class GraphRenderer
  include Contracts::DSL

  NODE_WIDTH = 120
  NODE_HEIGHT = 40
  FONT_SIZE_NAME = 9
  FONT_SIZE_DATE = 7

  public

  # Initialize the renderer with coordinates and person details.
  def initialize(coordinates, people, direction = :ancestry)
    @coordinates = coordinates
    @people = people
    @direction = direction
  end

  # Render the SVG to the specified output directory.
  # Filename is auto-generated with a timestamp to prevent overwrites.
  pre 'valid_output_dir' do |output_dir| Dir.exist?(output_dir) end
  def render(output_dir, root_id = "tree")
    nodes = @coordinates.nodes
    if nodes.empty? then
      puts "No nodes to render."
      return
    end

    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    filename = "family_tree_#{root_id}_#{timestamp}.svg"
    output_path = File.join(output_dir, filename)

    # Calculate canvas boundaries with padding
    min_x = nodes.values.map { |coord| coord[0] }.min
    min_y = nodes.values.map { |coord| coord[1] }.min
    max_x = nodes.values.map { |coord| coord[0] }.max
    max_y = nodes.values.map { |coord| coord[1] }.max

    offset_x = -min_x + 50
    offset_y = -min_y + 50

    width = max_x - min_x + NODE_WIDTH + 100
    height = max_y - min_y + NODE_HEIGHT + 100

    svg_lines = []
    svg_nodes = []

    # 1. Render Spousal Lines
    @coordinates.couples.each do |spouse1_id, spouse2_id|
      if @coordinates.has_node?(spouse1_id) &&
         @coordinates.has_node?(spouse2_id) then

        c1 = @coordinates.node(spouse1_id)
        c2 = @coordinates.node(spouse2_id)

        # Sort horizontally to draw line from left to right
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

    # 2. Render Parent-Child Lines
    nodes.each do |id, (x, y)|
      person = @people[id]
      next if person.nil?

      PARENTS.each do |parent_type|
        if person.respond_to?(parent_type) then
          parent_id = person.send(parent_type)
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

    # 3. Render Nodes (Boxes and Text)
    nodes.each do |id, (x, y)|
      person = @people[id]
      next if person.nil?

      nx = x + offset_x
      ny = y + offset_y

      # Using clean underscore getters mapped to hyphen keys
      name_label = "#{person.given_name} #{person.surname}".strip

      birth = person.respond_to?(:birth_date) ? person.birth_date : nil
      death = person.respond_to?(:death_date) ? person.death_date : nil

      b_str = birth.respond_to?(:year) ? birth.year.to_s : (birth || "").to_s
      d_str = death.respond_to?(:year) ? death.year.to_s : (death || "").to_s

      years_label = ""
      if !b_str.empty? || !d_str.empty? then
        years_label = "#{b_str}-#{d_str}"
      end

      svg_nodes << "  <rect x=\"#{nx}\" y=\"#{ny}\" width=\"#{NODE_WIDTH}\" " \
                   "height=\"#{NODE_HEIGHT}\" fill=\"white\" " \
                   "stroke=\"black\" />"
      svg_nodes << "  <text x=\"#{nx + NODE_WIDTH/2}\" y=\"#{ny + 15}\" " \
                   "font-family=\"Arial\" font-size=\"#{FONT_SIZE_NAME}\" " \
                   "text-anchor=\"middle\">#{name_label}</text>"
      svg_nodes << "  <text x=\"#{nx + NODE_WIDTH/2}\" y=\"#{ny + 30}\" " \
                   "font-family=\"Arial\" font-size=\"#{FONT_SIZE_DATE}\" " \
                   "text-anchor=\"middle\">#{years_label}</text>"
    end

    # SVG Template with arrowhead markers
    svg_template = <<~SVG
      <svg width="#{width}" height="#{height}" xmlns="http://www.w3.org/2000/svg">
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
end
