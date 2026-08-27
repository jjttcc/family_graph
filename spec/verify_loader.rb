require_relative '../src/data_loader'
require 'yaml'

# Assuming master_tree.yaml exists in the expected location
# We need to make sure we have access to the real data
data_path = '/home3/development/jtc/relatives/gemini/output-formatting/manual_engine/data/master_tree.yaml'

begin
  people = DataLoader.load(data_path)
  puts "Successfully loaded #{people.size} people."

  # Empirical verification of a known node
  # Let's check a person with both spouse and children
  person_id = 'william_frost_1713'
  person = people[person_id]

  if person
    puts "Verification for: #{person_id}"
    puts "  Given name: #{person.send('given-name')}"
    puts "  Has spouse: #{person.has_spouse}"
    puts "  Spouse: #{person.spouse.id if person.has_spouse}"
    puts "  Children count: #{person.children.size}"
    
    unless person.children.empty?
      puts "  First child: #{person.children.first.id}"
    end
  else
    puts "Person #{person_id} not found."
  end

rescue => e
  puts "Verification failed: #{e.message}"
  puts e.backtrace
end
