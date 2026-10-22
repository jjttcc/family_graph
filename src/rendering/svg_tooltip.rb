# vim: ts=2 sw=2 expandtab
require 'ruby_contracts'
require 'family_constants'

# Builds SVG hover tooltips (<title>) and forward-compatible data-* attributes
# for nodes (PersonNode or CoupleNode).
module SvgTooltip
  include Contracts::DSL

  public

  # The tooltip text (<title>) content containing all available node and person data
  pre :node_valid do |node| node.is_a?(Node) end
  def title(node)
    if node.is_a?(PersonNode) then
      person = node.person
      lines = []
      lines << "ID: #{person.id}"
      name = "#{person.given_name} #{person.surname}".strip
      if !name.empty? then
        lines << "Name: #{name}"
      end
      # Include all biographical data fields from person data hash
      if person.respond_to?(:send) then
        data_hash = person.send(:data) rescue nil
        if data_hash && data_hash.is_a?(Hash) then
          data_hash.each do |k, v|
            next if k == GNAME || k == SURNAME
            lines << "#{k.split('-').map(&:capitalize).join(' ')}: #{v}"
          end
        end
      end
      # Relationships
      parent_names = person.parents.map { |p|
        p.respond_to?(:person) ?
          "#{p.person.given_name} #{p.person.surname}".strip : p.id }
      if !parent_names.empty? then
        lines << "Parents: #{parent_names.join(', ')}"
      end
      spouse_names = person.spouses.map { |s|
        "#{s.given_name} #{s.surname}".strip }
      if !spouse_names.empty? then
        lines << "Spouses: #{spouse_names.join(', ')}"
      end
      child_names = person.children.map { |c|
        "#{c.given_name} #{c.surname}".strip }
      if !child_names.empty? then
        lines << "Children: #{child_names.join(', ')}"
      end
      lines.join("\n")
    elsif node.is_a?(CoupleNode) then
      p_a = node.person_a.person
      p_b = node.person_b.person
      name_a = "#{p_a.given_name} #{p_a.surname}".strip
      name_b = "#{p_b.given_name} #{p_b.surname}".strip
      lines = []
      lines << "Couple: #{name_a} & #{name_b}"
      lines << "Partner A ID: #{p_a.id}"
      lines << "Partner B ID: #{p_b.id}"
      # Shared or combined children
      child_names = node.children.map { |c|
        "#{c.given_name} #{c.surname}".strip }
      if !child_names.empty? then
        lines << "Children: #{child_names.join(', ')}"
      end
      lines.join("\n")
    else
      ""
    end
  end

  # The data-* attributes string for the node group (<g>).
  pre :node_valid do |node| node.is_a?(Node) end
  def data_attributes(node)
    if node.is_a?(PersonNode) then
      person = node.person
      attrs = "id=\"node_#{person.id}\" " \
              "data-person-id=\"#{person.id}\" " \
              "data-given-name=\"#{person.given_name}\" " \
              "data-surname=\"#{person.surname}\""
      if person.birth_date then
        attrs += " data-birth=\"#{person.birth_date}\""
      end
      if person.respond_to?(:death_date) && person.death_date then
        attrs += " data-death=\"#{person.death_date}\""
      end
      if person.respond_to?(:note) && person.note && !person.note.empty? then
        attrs += " data-note=\"#{person.note}\""
      end
      attrs
    elsif node.is_a?(CoupleNode) then
      "id=\"node_#{node.id}\" data-couple-id=\"#{node.id}\""
    else
      ""
    end
  end

end
