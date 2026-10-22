# vim: ts=2 sw=2 expandtab
require 'ruby_contracts'
require 'family_constants'

# Builds SVG hover tooltips (<title>) and forward-compatible data-* attributes
# for nodes (PersonNode or CoupleNode).
module SvgTooltip
  include Contracts::DSL

  public

  # The tooltip text (<title>) content for a given node
  pre :node_valid do |node| node.is_a?(Node) end
  def title(node)
    if node.is_a?(PersonNode) then
      person = node.person
      name = "#{person.given_name} #{person.surname}".strip
      date_str = person.birth_date ? "#{person.birth_date}" : ""
      if person.respond_to?(:death_date) && person.death_date then
        date_str += " - #{person.death_date}" if !date_str.empty?
        date_str = "#{person.death_date}" if date_str.empty?
      end
      title = name
      title += " (#{date_str})" unless date_str.empty?
      if person.respond_to?(:note) && person.note && !person.note.empty? then
        title += "\nNote: #{person.note}"
      end
      title
    elsif node.is_a?(CoupleNode) then
      p_a = node.person_a
      p_b = node.person_b
      name_a = "#{p_a.given_name} #{p_a.surname}".strip
      name_b = "#{p_b.given_name} #{p_b.surname}".strip
      "Couple: #{name_a} & #{name_b}"
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
