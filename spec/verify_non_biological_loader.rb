#!/bin/env ruby

ENV['FG_ROOT'] = 'src'
require_relative '../src/setup'
require 'data_loader'
require 'parent'
require 'biological_parent'
require 'non_biological_parent'
require 'family_constants'

puts "Verifying non-biological parent loading..."
people = DataLoader.load('data/non_biological_parents_test.yaml')

adopted = people['adopted_child_300']
raise "adopted_child_300 not found" unless adopted

puts "Adopted child parents count: #{adopted.parents.count}"
raise "Expected 2 parents for adopted_child_300, got #{adopted.parents.count}" unless adopted.parents.count == 2

adopted.parents.each do |p|
  puts "Parent ID: #{p.id}, Type: #{p.type}, Is biological?: #{p.is_biological}"
  raise "Expected adoptive parent type" unless p.type == ADOPTIVE
  raise "Expected is_biological to be false" if p.is_biological
end

assumed = people['assumed_child_400']
raise "assumed_child_400 not found" unless assumed

puts "Assumed child parents count: #{assumed.parents.count}"
raise "Expected 2 parents for assumed_child_400, got #{assumed.parents.count}" unless assumed.parents.count == 2

assumed.parents.each do |p|
  puts "Parent ID: #{p.id}, Type: #{p.type}, Is biological?: #{p.is_biological}"
  raise "Expected assumed parent type" unless p.type == ASSUMED
  raise "Expected is_biological to be false" if p.is_biological
end

puts "Non-biological parent loader verification PASSED!"
