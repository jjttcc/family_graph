require 'yaml'
require 'ruby_contracts'
require_relative 'person'
require_relative 'family_constants'

class DataLoader
  include Contracts::DSL

  public

  pre 'path_valid' do |yaml_path| yaml_path != nil end
  def self.load(yaml_path)
    data = YAML.unsafe_load_file(yaml_path)
    result = {}

    # 1. Create all Person objects
    data.each { |id, person_data| result[id] = Person.new(id, person_data) }

    # 2. Link relationships
    result.each_value do |person|
      # Link Spouses
      spouse_info = person.data[SPOUSE].to_s
      unless spouse_info.empty?
        spouse_id = spouse_info.split(',')[0].strip
        if result.key?(spouse_id) then
          spouse = result[spouse_id]
          person.add_spouse(spouse)

          # Ensure bi-directional link if missing
          unless spouse.spouse_list.include?(person)
            spouse.add_spouse(person)
          end
        end
      end

      # Link Parents/Children
      PARENTS.each do |parent_type|
        parent_id = person.data[parent_type]
        if parent_id && result.key?(parent_id)
          result[parent_id].add_child(person)
        end
      end
    end

    result
  end
end

