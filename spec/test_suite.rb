require_relative '../src/data_loader'
require_relative '../src/family_constants'

def assert(condition, message)
  unless condition
    puts "Assertion Failed: #{message}"
    exit 1
  end
end

data_path = '/home3/development/jtc/relatives/gemini/output-formatting/manual_engine/data/master_tree.yaml'
people = DataLoader.load(data_path)
puts "Successfully loaded #{people.size} people."

# Define test cases: { id => expected_children_count }
# Checking a mix of roots, intermediate nodes, and leaves
test_cases = {
  'john_frost_1680' => 3,     # Root
  'william_frost_1713' => 6,  # Intermediate
  'james_frost_1751' => 1,    # Intermediate
  'walter_westcott_1742' => 1,# Intermediate
  'elizabeth_westcott_1834' => 0, # Leaf
  'ann_frost_1741' => 0,      # Leaf
  'robert_frost_1710' => 0,   # Leaf
  'john_westcott_1756' => 2   # Intermediate
}

puts "Running extensive structural assertions..."

test_cases.each do |id, expected_children|
  person = people[id]
  assert(person != nil, "Person #{id} should exist")
  assert(person.children.size == expected_children, 
         "#{id} should have #{expected_children} children, but has #{person.children.size}")
  
  # Verify bidirectional linking (child's parent should be this person)
  person.children.each do |child|
    parent_id = child.data[FATHER] || child.data[MOTHER]
    assert(parent_id == id, 
           "Child #{child.id} of #{id} should have #{id} as parent, but has #{parent_id}")
  end
end

puts "All #{test_cases.size} structural assertions passed!"
