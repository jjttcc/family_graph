# vim: ts=2 sw=2 expandtab
require 'ruby_contracts'
require 'family_constants'

# Builds SVG hover tooltips (<title>) and forward-compatible data-* attributes
# for nodes (PersonNode or CoupleNode).
module SVGTooltip
  include Contracts::DSL

  public

  # The tooltip content containing all available node and person data
  pre :node_valid do |node| node.is_a?(PersonNode) end
  def tooltip_content(node)
    result = ""
    person = node.person
    data_hash = person.send(:data) rescue {}
    data_hash ||= {}
    lines = []
    lines << formatted_id_line(person)
    lines << formatted_name_line(person, data_hash)
    lines << formatted_mother_line(person)
    lines << formatted_father_line(person)
    lines.concat(formatted_non_biological_mother_lines(person))
    lines.concat(formatted_non_biological_father_lines(person))
    lines << formatted_spouse_lines(person)
    lines << formatted_child_lines(person)
    lines.concat(formatted_date_lines(person, data_hash))
    lines.concat(formatted_remaining_field_lines(person, data_hash))
    lines << formatted_note_line(person, data_hash)
    result = lines.compact.reject(&:empty?).join("\n")
    result
  end

  private ###  Helper Methods

  # Formatted ID line
  def formatted_id_line(person)
    result = "ID: #{person.id}"
    result
  end

  # Formatted name line
  def formatted_name_line(person, data_hash)
    result = ""
    middle_name = data_hash['middle-name'] || data_hash['middle_name']
    full_name = [person.given_name, middle_name,
                 person.surname].compact.join(' ')
    if !full_name.empty? then
      result = "Name: #{full_name}"
    end
    result
  end

  # Formatted biological mother line
  def formatted_mother_line(person)
    result = ""
    if person.mother then
      m_person = person.mother.person
      m_mid = m_person.send(:data)['middle-name'] rescue nil
      m_name = [m_person.given_name, m_mid,
                m_person.surname].compact.join(' ')
      if !m_name.empty? then
        result = "Mother: #{m_name}"
      end
    end
    result
  end

  # Formatted biological father line
  def formatted_father_line(person)
    result = ""
    if person.father then
      f_person = person.father.person
      f_mid = f_person.send(:data)['middle-name'] rescue nil
      f_name = [f_person.given_name, f_mid,
                f_person.surname].compact.join(' ')
      if !f_name.empty? then
        result = "Father: #{f_name}"
      end
    end
    result
  end

  # Formatted non-biological mother lines
  def formatted_non_biological_mother_lines(person)
    result = []
    if person.non_biological_mothers then
      person.non_biological_mothers.each do |nbm|
        nbm_person = nbm.person
        nbm_mid = nbm_person.send(:data)['middle-name'] rescue nil
        nbm_name = [nbm_person.given_name, nbm_mid,
                    nbm_person.surname].compact.join(' ')
        type_str = nbm.type.to_s.capitalize
        if !nbm_name.empty? then
          result << "#{type_str} Mother: #{nbm_name}"
        end
      end
    end
    result
  end

  # Formatted non-biological father lines
  def formatted_non_biological_father_lines(person)
    result = []
    if person.non_biological_fathers then
      person.non_biological_fathers.each do |nbf|
        nbf_person = nbf.person
        nbf_mid = nbf_person.send(:data)['middle-name'] rescue nil
        nbf_name = [nbf_person.given_name, nbf_mid,
                    nbf_person.surname].compact.join(' ')
        type_str = nbf.type.to_s.capitalize
        if !nbf_name.empty? then
          result << "#{type_str} Father: #{nbf_name}"
        end
      end
    end
    result
  end

  # Formatted spouse lines
  def formatted_spouse_lines(person)
    result = ""
    if person.spouses && !person.spouses.empty? then
      spouse_descs = person.spouses.map do |s|
        s_mid = s.send(:data)['middle-name'] rescue nil
        s_name = [s.given_name, s_mid, s.surname].compact.join(' ')
        s_data = s.send(:data) rescue {}
        m_date = nil
        m_place = nil
        if person.spouse_metadata && person.spouse_metadata[s.id] then
          meta = person.spouse_metadata[s.id]
          m_date = meta[:date]
          m_place = meta[:place]
        end
        if !m_date then
          m_date = s_data['marriage-date'] || s_data['marriage_date'] ||
                   s_data['spouse-date']
        end
        if !m_place then
          m_place = s_data['marriage-place'] || s_data['marriage_place']
        end
        extra_info = []
        if m_date && !m_date.empty? then
          extra_info << m_date
        end
        if m_place && !m_place.empty? then
          extra_info << m_place
        end
        if !extra_info.empty? then
          "#{s_name} (#{extra_info.join('; ')})"
        else
          s_name
        end
      end
      result = "Spouses: #{spouse_descs.join('; ')}"
    end
    result
  end

  # Formatted child lines
  def formatted_child_lines(person)
    result = ""
    if person.children && !person.children.empty? then
      child_names = person.children.map do |c|
        c_mid = c.send(:data)['middle-name'] rescue nil
        [c.given_name, c_mid, c.surname].compact.join(' ')
      end
      result = "Children: #{child_names.join(', ')}"
    end
    result
  end

  # Formatted date lines
  def formatted_date_lines(person, data_hash)
    result = []
    birth_val = person.birth_date || data_hash['birth-date'] ||
                data_hash['birth_date']
    if birth_val then
      result << "Birth Date: #{birth_val}"
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
      result.concat(other_dates)
    end
    result
  end

  # Formatted remaining field lines
  def formatted_remaining_field_lines(person, data_hash)
    result = []
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
      formatted_val = formatted_structured_value(v)
      result << "#{formatted_key}: #{formatted_val}"
    end
    result
  end

  # Formatted note line
  def formatted_note_line(person, data_hash)
    result = ""
    note_val = data_hash['note'] || data_hash['notes']
    if note_val && !note_val.to_s.empty? then
      result = "Note: #{note_val}"
    end
    result
  end

  # Formats structured values (hashes, arrays of hashes)
  # into human-readable strings.
  def formatted_structured_value(v)
    result = ""
    if v.is_a?(Array) then
      result = v.map do |item|
        item_str = ""
        if item.is_a?(Hash) then
          date_val = item['date'] || item[:date]
          loc_val = item['location'] || item[:location] ||
                    item['place'] || item[:place]
          note_val = item['notes'] || item[:notes]
          res_str = [date_val, loc_val].compact.join(' - ')
          if res_str.empty? then
            res_str = item.map { |k, val| "#{k}: #{val}" }.join(', ')
          end
          if note_val then
            res_str += " (#{note_val})"
          end
          item_str = res_str
        else
          item_str = item.to_s
        end
        item_str
      end.join('; ')
    elsif v.is_a?(Hash) then
      result = v.map { |k, val| "#{k}: #{val}" }.join('; ')
    else
      result = v.to_s
    end
    result
  end

  # The data-* attributes string for the node group (<g>).
  pre :node_valid do |node| node.is_a?(Node) end
  def data_attributes(node)
    result = ""
    if node.is_a?(PersonNode) then
      person = node.person
      attrs = "id=\"node_#{person.id}\" " \
              "data-person-id=\"#{person.id}\" " \
              "data-given-name=\"#{person.given_name}\" " \
              "data-surname=\"#{person.surname}\""
      birth_val = person.birth_date
      if birth_val && birth_val != DATA_NOT_AVAILABLE then
        attrs += " data-birth=\"#{birth_val}\""
      end
      death_val = person.death_date
      if death_val && death_val != DATA_NOT_AVAILABLE then
        attrs += " data-death=\"#{death_val}\""
      end
      data_hash = person.send(:data) rescue {}
      data_hash ||= {}
      note_val = data_hash['note'] || data_hash['notes']
      if note_val && !note_val.to_s.empty? then
        attrs += " data-note=\"#{note_val}\""
      end
      result = attrs
    elsif node.is_a?(CoupleNode) then
      result = "id=\"node_#{node.id}\" data-couple-id=\"#{node.id}\""
    else
      result = ""
    end
    result
  end

end
