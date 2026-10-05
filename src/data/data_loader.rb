require 'yaml'
require 'ruby_contracts'
require 'person'
require 'biological_parent'
require 'non_biological_parent'
require 'family_constants'

# Loads genealogical data from YAML files and builds Person object structures.
class DataLoader
  include Contracts::DSL

  public

  # Loads genealogical data from YAML files.
  # If target_ids is provided, only loads the subset of people.
  pre :path_valid do |yaml_path| yaml_path != nil end
  def self.load(yaml_path, target_ids = nil)
    data = YAML.unsafe_load_file(yaml_path)
    # Filter if target_ids is provided
    if target_ids then
      data = data.select { |id, _| target_ids.member?(id) }
    end
    result = {}
    # 1. Create Person objects
    data.each { |id, person_data| result[id] = Person.new(id, person_data) }
    # 2. Link relationships
    link_relationships(result)
    result
  end

  private

  def self.link_relationships(person_table)
    person_table.each_value do |person|
      # Link Spouses
      spouse_info = person.send(:data)[SPOUSE].to_s
      if spouse_info.empty? then
        spouse_info = person.send(:data)[SPOUSES].to_s
      end
      if ! spouse_info.empty? then
        spouse_ids = spouse_info.split(',').map(&:strip)
        spouse_ids.each do |spouse_id|
          if person_table.key?(spouse_id) then
            spouse = person_table[spouse_id]
            # Ensure links are added only once to prevent errors
            if !person.spouses.include?(spouse) then
              person.add_spouse(spouse)
            end
            if !spouse.spouses.include?(person) then
              spouse.add_spouse(person)
            end
          end
        end
      end
      # Link Parents/Children
      PARENTS.each do |parent_type|
        parent_id = person.send(:data)[parent_type]
        if parent_id && person_table.key?(parent_id) then
          parent_person = person_table[parent_id]
          parent_person.add_child(person)
          if parent_type == FATHER then
            person.father = BiologicalParent.new(parent_person)
          else
            person.mother = BiologicalParent.new(parent_person)
          end
        end
      end

      # Link Non-Biological Parents
      [
        [ADOPTIVE_FATHER, ADOPTIVE, :non_biological_fathers],
        [ASSUMED_FATHER, ASSUMED, :non_biological_fathers],
        [ADOPTIVE_MOTHER, ADOPTIVE, :non_biological_mothers],
        [ASSUMED_MOTHER, ASSUMED, :non_biological_mothers]
      ].each do |field_name, parent_type, collection_sym|
        parent_id = person.send(:data)[field_name]
        if parent_id && person_table.key?(parent_id) then
          parent_person = person_table[parent_id]
          parent_person.add_child(person)
          non_bio_parent = NonBiologicalParent.new(parent_person, parent_type)
          person.send(collection_sym) << non_bio_parent
        end
      end
    end
  end

end
