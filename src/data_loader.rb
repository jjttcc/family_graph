require 'yaml'
require 'ruby_contracts'
require_relative 'person'
require_relative 'family_constants'

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

  def self.link_relationships(result)
    result.each_value do |person|
      # Link Spouses
      spouse_info = person.send(:data)[SPOUSE].to_s
      if spouse_info.empty? then
        spouse_info = person.send(:data)[SPOUSES].to_s
      end
      if ! spouse_info.empty? then
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
        parent_id = person.send(:data)[parent_type]
        if parent_id && result.key?(parent_id) then
          parent = result[parent_id]
          parent.add_child(person)
          if parent_type == FATHER
            person.father = parent
          else
            person.mother = parent
          end
        end
      end
    end
  end

end
