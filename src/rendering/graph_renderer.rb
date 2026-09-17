require 'ruby_contracts'
require 'debug_logger'
require 'family_constants'
require 'relationship_connection_finder'
require 'svg_utility'

# Renders the calculated genealogical coordinates into an SVG diagram.
class GraphRenderer
  include Contracts::DSL, SVGUtility

  public

  # Initialize renderer. Label mode: :dates, :ids, or :both.
  def initialize(coordinates, people, direction = ANCESTRY,
                 label_mode = :dates)
    @coordinates = coordinates
    @people = people
    @direction = direction
    @label_mode = label_mode
    @coordinate_finder = RelationshipConnectionFinder.new(people)
    validate_coordinates
  end

  # Render SVG to specified directory.
  pre :valid_output_dir do |output_dir| Dir.exist?(output_dir) end
  def render(output_dir, root_id = "tree")
    if @coordinates.nodes.empty? then
      puts "No nodes to render."
      return
    end
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    filename = "family_tree_#{root_id}_#{timestamp}.svg"
    output_path = File.join(output_dir, filename)
    offset_x, offset_y, width, height = calculate_dimensions_all_sets
    svg_lines = []
    svg_nodes = []
    @people.each do |id, person|
      if person.coordinate_sets.empty? then
        next
      end
      if !person.has_spouse then
        coord = person.self_coordinates
        if coord then
          render_person(person, coord[0], coord[1], svg_nodes,
                        offset_x, offset_y)
        end
      else
        person.coordinate_sets.each do |context_id, (x, y)|
          if context_id && context_id != Person::SELF then
            render_person(person, x, y, svg_nodes, offset_x, offset_y)
          end
        end
      end
    end
    rendered_couples = Set.new
    @coordinates.couples.each do |s1_id, s2_id|
      couple_id = [s1_id, s2_id].sort
      if rendered_couples.include?(couple_id) then
        next
      end
      render_spousal_line(s1_id, s2_id, svg_lines, offset_x, offset_y)
      rendered_couples.add(couple_id)
    end
    render_parent_child_lines(svg_lines, offset_x, offset_y)
    svg_template = template(width, height, svg_lines, svg_nodes)
    File.write(output_path, svg_template)
    puts "Successfully rendered SVG to #{output_path}"
  end

  private

  def validate_coordinates
    @people.each do |id, person|
      if person.coordinate_sets.empty? then
        puts "Warning: Person #{id} has no coordinate sets!"
      end
    end
  end

  def calculate_dimensions_all_sets
    all_coords = []
    @people.each do |id, person|
      person.instance_variable_get(:@coordinate_sets).values.each do |(x, y)|
        all_coords << [x, y]
      end
    end
    min_x = all_coords.map { |c| c[0] }.min
    min_y = all_coords.map { |c| c[1] }.min
    max_x = all_coords.map { |c| c[0] }.max
    max_y = all_coords.map { |c| c[1] }.max
    offset_x = -min_x + RENDER_OFFSET_X
    offset_y = -min_y + RENDER_OFFSET_Y
    width = max_x - min_x + NODE_WIDTH + (2 * RENDER_OFFSET_X)
    height = max_y - min_y + NODE_HEIGHT + (2 * RENDER_OFFSET_Y)
    [offset_x, offset_y, width, height]
  end

  def render_spousal_line(s1_id, s2_id, svg_lines, offset_x, offset_y)
    p1 = @people[s1_id]
    p2 = @people[s2_id]
    if !p1 || !p2 then
      return
    end
    c1 = p1.coordinate_set(s2_id)
    c2 = p2.coordinate_set(s1_id)
    if !c1 || !c2 then
      return
    end
    left_c, right_c = [c1, c2].sort_by { |c| c[0] }
    x1 = left_c[0] + NODE_WIDTH + offset_x
    y1 = left_c[1] + (NODE_HEIGHT / 2) + offset_y
    x2 = right_c[0] + offset_x
    y2 = right_c[1] + (NODE_HEIGHT / 2) + offset_y
    svg_lines << line(x1, y1, x2, y2, 'black', 1, '4')
  end

  def render_person(person, x, y, svg_nodes, offset_x, offset_y)
    nx = x + offset_x
    ny = y + offset_y
    name_label = "#{person.given_name} #{person.surname}".strip
    if person.spouses.size > 1 then
      name_label += " +"
    end
    birth = person.respond_to?(:birth_date) ? person.birth_date : nil
    death = person.respond_to?(:death_date) ? person.death_date : nil
    b_str = (birth || "").to_s
    if b_str.empty? then
      bap = person.respond_to?(:baptism_date) ? person.baptism_date : nil
      b_str = (bap || "").to_s
      if !b_str.empty? then
        b_str += " [bap]"
      end
    end
    d_str = (death || "").to_s
    date_label = "#{b_str}, #{d_str}".gsub(/^, |, $/, "")
    texts = []
    texts << ["#{nx + NODE_WIDTH / 2}", "#{ny + TEXT_NAME_Y_OFFSET}",
              name_label, 9]
    case @label_mode
    when :dates then
      texts << ["#{nx + NODE_WIDTH / 2}", "#{ny + TEXT_DATE_Y_OFFSET}",
                date_label, 7]
    when :ids then
      texts << ["#{nx + NODE_WIDTH / 2}", "#{ny + TEXT_ID_Y_OFFSET}",
                person.id, 7]
    when :both then
      texts << ["#{nx + NODE_WIDTH / 2}", "#{ny + TEXT_DATE_BOTH_Y_OFFSET}",
                date_label, 7]
      texts << ["#{nx + NODE_WIDTH / 2}", "#{ny + TEXT_ID_BOTH_Y_OFFSET}",
                person.id, 7]
    end
    svg_nodes << rect(nx, ny, NODE_WIDTH, NODE_HEIGHT)
    texts.each do |x_pos, y_pos, label, size|
      svg_nodes << text(x_pos, y_pos, label, size)
    end
  end

  def render_parent_child_lines(svg_lines, offset_x, offset_y)
    DebugLogger.log("DEBUG: render_parent_child_lines called.")
    @people.each do |id, person|
      person.coordinate_sets.each do |context_id, (cx, cy)|
        person.parents.each do |parent|
          parent_coord = @coordinate_finder.find(parent, context_id)
          DebugLogger.log(["DEBUG: Rendering line for child #{person.id}",
                           "context: #{context_id.inspect}",
                           "parent: #{parent.id}",
                           "coord: #{parent_coord.inspect}"], "\n")
          if !parent_coord then
            next
          end
          px, py = parent_coord
          if @direction == DESCENT then
            x1 = px + (NODE_WIDTH / 2) + offset_x
            y1 = py + NODE_HEIGHT + offset_y
            x2 = cx + (NODE_WIDTH / 2) + offset_x
            y2 = cy + offset_y
          else
            x1 = cx + (NODE_WIDTH / 2) + offset_x
            y1 = cy + offset_y
            x2 = px + (NODE_WIDTH / 2) + offset_x
            y2 = py + NODE_HEIGHT + offset_y
          end
          marker = (@direction == NONE) ? "" : " marker-end=\"url(#arrowhead)\""
          svg_lines << line(x1, y1, x2, y2, 'black', 1, nil, marker != "")
        end
      end
    end
  end

end
