# vim: ts=2 sw=2 expandtab
require 'ruby_contracts'
require 'family_constants'

# Builds SVG hover tooltips (<title>) and forward-compatible data-* attributes
# for nodes (PersonNode or CoupleNode).
module SvgTooltip
  include Contracts::DSL

  public

  # The tooltip content containing all available node and person data
  pre :node_valid do |node| node.is_a?(Node) end
  def tooltip_content(node)
    if node.is_a?(PersonNode) then
      person = node.person
      lines = []
      # 1. ID
      lines << "ID: #{person.id}"
      # 2. Name (first, middle, and last)
      data_hash = person.send(:data) rescue {}
      data_hash ||= {}
      middle_name = data_hash['middle-name'] || data_hash['middle_name']
      full_name = [person.given_name, middle_name,
                   person.surname].compact.join(' ')
      if !full_name.empty? then
        lines << "Name: #{full_name}"
      end
      # 3. Mother (biological)
      if person.respond_to?(:mother) && person.mother then
        m_person = person.mother.person
        m_mid = m_person.send(:data)['middle-name'] rescue nil
        m_name = [m_person.given_name, m_mid,
                  m_person.surname].compact.join(' ')
        if !m_name.empty? then
          lines << "Mother: #{m_name}"
        end
      end
      # 4. Father (biological)
      if person.respond_to?(:father) && person.father then
        f_person = person.father.person
        f_mid = f_person.send(:data)['middle-name'] rescue nil
        f_name = [f_person.given_name, f_mid,
                  f_person.surname].compact.join(' ')
        if !f_name.empty? then
          lines << "Father: #{f_name}"
        end
      end
      # 5. Non-biological mothers and fathers (adoptive, assumed, etc.)
      if person.respond_to?(:non_biological_mothers) &&
         person.non_biological_mothers then
        person.non_biological_mothers.each do |nbm|
          nbm_person = nbm.person
          nbm_mid = nbm_person.send(:data)['middle-name'] rescue nil
          nbm_name = [nbm_person.given_name, nbm_mid,
                      nbm_person.surname].compact.join(' ')
          type_str = nbm.type.to_s.capitalize
          if !nbm_name.empty? then
            lines << "#{type_str} Mother: #{nbm_name}"
          end
        end
      end
      if person.respond_to?(:non_biological_fathers) &&
         person.non_biological_fathers then
        person.non_biological_fathers.each do |nbf|
          nbf_person = nbf.person
          nbf_mid = nbf_person.send(:data)['middle-name'] rescue nil
          nbf_name = [nbf_person.given_name, nbf_mid,
                      nbf_person.surname].compact.join(' ')
          type_str = nbf.type.to_s.capitalize
          if !nbf_name.empty? then
            lines << "#{type_str} Father: #{nbf_name}"
          end
        end
      end
      # 6. Spouses (including date and place of marriage if available)
      if person.respond_to?(:spouses) && !person.spouses.empty? then
        spouse_descs = person.spouses.map do |s|
          s_mid = s.send(:data)['middle-name'] rescue nil
          s_name = [s.given_name, s_mid, s.surname].compact.join(' ')
          s_data = s.send(:data) rescue {}
          m_date = s_data['marriage-date'] || s_data['marriage_date'] ||
                   s_data['spouse-date']
          m_place = s_data['marriage-place'] || s_data['marriage_place']
          extra_info = []
          if m_date then
            extra_info << "Marriage Date: #{m_date}"
          end
          if m_place then
            extra_info << "Marriage Place: #{m_place}"
          end
          if !extra_info.empty? then
            "#{s_name} (#{extra_info.join(', ')})"
          else
            s_name
          end
        end
        lines << "Spouses: #{spouse_descs.join('; ')}"
      end
      # 7. Children
      if person.respond_to?(:children) && !person.children.empty? then
        child_names = person.children.map do |c|
          c_mid = c.send(:data)['middle-name'] rescue nil
          [c.given_name, c_mid, c.surname].compact.join(' ')
        end
        lines << "Children: #{child_names.join(', ')}"
      end
      # 8. Birth date followed by all other dates
      birth_val = person.birth_date || data_hash['birth-date'] ||
                  data_hash['birth_date']
      if birth_val then
        lines << "Birth Date: #{birth_val}"
      end
      other_dates = []
      data_hash.each do |k, v|
        k_str = k.to_s
        if (k_str.include?('date') || k_str.include?('Date')) &&
           k_str != 'birth-date' && k_str != 'birth_date' then
          formatted_key = k_str.split('-').map(&:capitalize).join(' ')
          other_dates << "#{formatted_key}: #{v}"
        end
      end
      if !other_dates.empty? then
        lines.concat(other_dates)
      end
      # 9. Any remaining fields except for notes
      data_hash.each do |k, v|
        k_str = k.to_s
        next if k_str == GNAME || k_str == SURNAME ||
                k_str == 'middle-name' || k_str == 'middle_name'
        next if k_str.include?('date') || k_str.include?('Date')
        next if k_str == 'father' || k_str == 'mother' ||
                k_str == 'adoptive-father' || k_str == 'adoptive-mother' ||
                k_str == 'assumed-father' || k_str == 'assumed-mother' ||
                k_str == 'spouse' || k_str == 'spouses'
        next if k_str == 'note' || k_str == 'notes'
        formatted_key = k_str.split('-').map(&:capitalize).join(' ')
        lines << "#{formatted_key}: #{v}"
      end
      # 10. Notes (if any, always last)
      note_val = data_hash['note'] || data_hash['notes']
      if person.respond_to?(:note) && person.note && !person.note.empty? then
        note_val = person.note
      end
      if note_val && !note_val.to_s.empty? then
        lines << "Note: #{note_val}"
      end
      lines.join("\n")
    elsif node.is_a?(CoupleNode) then
      p_a = node.person_a.person
      p_b = node.person_b.person
      mid_a = p_a.send(:data)['middle-name'] rescue nil
      mid_b = p_b.send(:data)['middle-name'] rescue nil
      name_a = [p_a.given_name, mid_a, p_a.surname].compact.join(' ')
      name_b = [p_b.given_name, mid_b, p_b.surname].compact.join(' ')
      lines = []
      lines << "Couple: #{name_a} & #{name_b}"
      lines << "Partner A ID: #{p_a.id}"
      lines << "Partner B ID: #{p_b.id}"
      if node.respond_to?(:children) && !node.children.empty? then
        child_names = node.children.map do |c|
          c_mid = c.send(:data)['middle-name'] rescue nil
          [c.given_name, c_mid, c.surname].compact.join(' ')
        end
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
