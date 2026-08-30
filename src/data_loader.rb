require 'yaml'
require 'ruby_contracts'
require_relative 'person'
require_relative 'family_constants'

class DataLoader
  include Contracts::DSL

  public

  pre :path_valid do |yaml_path| yaml_path != nil end
  def self.load(yaml_path)
    data = YAML.unsafe_load_file(yaml_path)
    result = {}
    # 1. Create all Person objects
    data.each { |id, person_data| result[id] = Person.new(id, person_data) }
    # 2. Link relationships
    result.each_value do |person|
      # Link Spouses
      spouse_info = person.data[SPOUSE].to_s
      spouse_info = person.data[SPOUSES].to_s if spouse_info.empty?
      
      unless spouse_info.empty?
        spouse_ids = spouse_info.split(',').map(&:strip)
        spouse_ids.each do |spouse_id|
          if result.key?(spouse_id) then
            spouse = result[spouse_id]
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
        parent_id = person.data[parent_type]
        if parent_id && result.key?(parent_id) then
          parent = result[parent_id]
          parent.add_child(person)
          if parent_type == FATHER
            person.father = parent
            person.father_id = parent_id
          else
            person.mother = parent
            person.mother_id = parent_id
          end
        end
      end
    end

    result
  end
end

