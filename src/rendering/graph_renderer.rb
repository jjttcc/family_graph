require 'ruby_contracts'
require 'debug_logger'
require 'family_constants'
require 'svg_utility'

# Renders the calculated node registry into an SVG diagram.
class GraphRenderer
  include Contracts::DSL, SVGUtility

  public  ###  Initialization

  def initialize(coordinates, direction = ANCESTRY, label_mode = :dates)
    @coordinates = coordinates
    @direction = direction
    @label_mode = label_mode
  end

  public  ###  Basic operations

  # Renders the registered family tree structure into an SVG file.
  # @param output_dir [String] The directory path where the SVG is saved.
  # @param root_id [String] The identifier for the root of the tree.
  def render(output_dir, root_id = "tree")
    if @coordinates.single_nodes.empty? && @coordinates.couples.empty? then
      puts "No nodes to render."
      return
    end
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    filename = "family_tree_#{root_id}_#{timestamp}.svg"
    output_path = File.join(output_dir, filename)
    offset_x, offset_y, width, height = calculate_dimensions
    svg_lines = []
    svg_nodes = []
    # render "single-person" nodes
    @coordinates.single_nodes.values.each do |node|
      render_person(node, svg_nodes, offset_x, offset_y)
    end
    # render "married-person" nodes
    @coordinates.couples.values.each do |couple|
      render_couple(couple, svg_lines, svg_nodes, offset_x, offset_y)
    end
    render_parent_child_lines(svg_lines, offset_x, offset_y)
    svg_template = template(width, height, svg_lines, svg_nodes)
    File.write(output_path, svg_template)
    puts "Successfully rendered SVG to #{output_path}"
  end

  private

  # Calculates the total SVG dimensions and canvas offset to contain all nodes.
  # @return [Array<Numeric>] offset_x, offset_y, width, height.
  def calculate_dimensions
    all_nodes = @coordinates.single_nodes.values +
                @coordinates.couples.values.flat_map { |c| [c.partner_a,
                                                            c.partner_b] }
    min_x = all_nodes.map { |n| n.x }.min
    min_y = all_nodes.map { |n| n.y }.min
    max_x = all_nodes.map { |n| n.x + NODE_WIDTH }.max
    max_y = all_nodes.map { |n| n.y + NODE_HEIGHT }.max
    [-min_x + RENDER_OFFSET_X, -min_y + RENDER_OFFSET_Y,
     max_x - min_x + NODE_WIDTH + (2 * RENDER_OFFSET_X),
     max_y - min_y + NODE_HEIGHT + (2 * RENDER_OFFSET_Y)]
  end

  # Renders an individual person node as a rectangle with text labels.
  # @param node [PersonNode] The node representing the person.
  # @param svg_nodes [Array] The collection of SVG elements to add to.
  # @param offset_x [Numeric] X-axis offset for rendering.
  # @param offset_y [Numeric] Y-axis offset for rendering.
  def render_person(node, svg_nodes, offset_x, offset_y)
    nx = node.x + offset_x
    ny = node.y + offset_y
    name_label = "#{node.given_name} #{node.surname}".strip
    texts = [["#{nx + NODE_WIDTH / 2}", "#{ny + TEXT_NAME_Y_OFFSET}",
              name_label, 9]]
    if node.respond_to?(:baptism_date) && node.baptism_date then
      date = "#{node.baptism_date} [bap]"
    else
      date = node.birth_date
    end
    date_label = (date || "").to_s
    case @label_mode
    when :dates then
      texts << ["#{nx + NODE_WIDTH / 2}", "#{ny + TEXT_DATE_Y_OFFSET}",
                date_label, 7]
    when :ids then
      texts << ["#{nx + NODE_WIDTH / 2}", "#{ny + TEXT_ID_Y_OFFSET}",
                node.id, 7]
    when :both then
      texts << ["#{nx + NODE_WIDTH / 2}", "#{ny + TEXT_DATE_BOTH_Y_OFFSET}",
                date_label, 7]
      texts << ["#{nx + NODE_WIDTH / 2}", "#{ny + TEXT_ID_BOTH_Y_OFFSET}",
                node.id, 7]
    end
    # Multi-spouse representation indicator
    if node.person.spouses.size > 1 then
      symbol = node.is_primary_representation ? "*" : "+"
      texts << ["#{nx + NODE_WIDTH - 10}", "#{ny + 15}", symbol, 10]
    end
    svg_nodes << rect(nx, ny, NODE_WIDTH, NODE_HEIGHT)
    texts.each { |x, y, l, s| svg_nodes << text(x, y, l, s) }
  end

  # Renders a couple, including their individual nodes and the spousal line.
  # @param couple [CoupleNode] The couple node to render.
  # @param svg_lines [Array] Collection of SVG line elements.
  # @param svg_nodes [Array] Collection of SVG node elements.
  # @param offset_x [Numeric] X-axis offset for rendering.
  # @param offset_y [Numeric] Y-axis offset for rendering.
  def render_couple(couple, svg_lines, svg_nodes, offset_x, offset_y)
    # Render partner nodes
    render_person(couple.partner_a, svg_nodes, offset_x, offset_y)
    render_person(couple.partner_b, svg_nodes, offset_x, offset_y)
    # Render spousal line
    left_n, right_n = [couple.partner_a, couple.partner_b].sort_by { |n| n.x }
    x1 = left_n.x + NODE_WIDTH + offset_x
    y1 = left_n.y + (NODE_HEIGHT / 2) + offset_y
    x2 = right_n.x + offset_x
    y2 = right_n.y + (NODE_HEIGHT / 2) + offset_y
    svg_lines << line(x1, y1, x2, y2, 'black', 1, '4')
  end

  # Renders lines connecting children to their respective parents.
  # @param svg_lines [Array] Collection of SVG line elements.
  # @param offset_x [Numeric] X-axis offset for rendering.
  # @param offset_y [Numeric] Y-axis offset for rendering.
  def render_parent_child_lines(svg_lines, offset_x, offset_y)
    @coordinates.all_person_nodes.each do |node|
      if node.is_a?(PersonNode) && node.is_primary_representation then
        person = node.person
        person.parents.each do |parent|
          parent_node = @coordinates.node_for_person(parent)
          if parent_node then
            x1, y1 = node.top_center
            x2, y2 = parent_node.bottom_center
            marker = if @direction == NONE then
              ""
            else
              " marker-end=\"url(#arrowhead)\""
            end
            svg_lines << line(x1 + offset_x, y1 + offset_y, x2 + offset_x,
                              y2 + offset_y, 'black', 1, nil, marker != "")
          end
        end
      end
    end
  end

end
