#!/bin/env ruby

require_relative '../src/data_loader'
require 'yaml'

# Load the anonymous test fixture
data_path = 'spec/data/test_tree.yaml'

def assert(condition, message)
  unless condition
    puts "Verification FAILED: #{message}"
    exit 1
  end
end

begin
  # Count YAML entries manually to verify loader's accuracy
  yaml_content = File.read(data_path)
  expected_count = yaml_content.scan(/^[a-z0-9_-]+:/i).size
  people = DataLoader.load(data_path)
  puts "Successfully loaded #{people.size} people."
  assert(
    people.size == expected_count,
    "Loaded count #{people.size} does not match YAML entry " +
    "count #{expected_count}"
  )
  # Empirical verification of a known node
  # Let's check a person with both spouse and children
  person_id = 'william_test_1900'
  person = people[person_id]
  if person
    puts "Verification for: #{person_id}"
    puts "  Given name: #{person.send('given-name')}"
    puts "  Has spouse: #{person.has_spouse}"
    person.spouses.each do |spouse|
      puts "  Spouse: #{spouse.id}"
    end
  else
    puts "Person #{person_id} not found."
  end
rescue => e
  puts "Verification FAILED: #{e.message}"
  puts e.backtrace
end
