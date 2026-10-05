#!/usr/bin/env ruby

root = 'FG_ROOT'
root_path = ENV[root]
setup_path = "#{root_path}/setup.rb"
if ! ENV[root] then
  $stderr.puts "environment variable #{root} must be set."
  exit 2
end
require setup_path
require 'line_style_map'
require 'person'
require 'biological_parent'
require 'non_biological_parent'
require 'family_constants'

puts "Verifying LineStyleMap..."

person = Person.new('test_person')
bio_parent = BiologicalParent.new(person)
adoptive_parent = NonBiologicalParent.new(person, ADOPTIVE)
assumed_parent = NonBiologicalParent.new(person, ASSUMED)

bio_style = LineStyleMap.style_for(bio_parent)
raise "Expected nil dasharray for biological parent" unless bio_style[:stroke_dasharray].nil?

adoptive_style = LineStyleMap.style_for(adoptive_parent)
raise "Expected '1, 4' dasharray for adoptive parent" unless adoptive_style[:stroke_dasharray] == '1, 4'
raise "Expected 'round' linecap for adoptive parent" unless adoptive_style[:stroke_linecap] == 'round'

assumed_style = LineStyleMap.style_for(assumed_parent)
raise "Expected '8, 4' dasharray for assumed parent" unless assumed_style[:stroke_dasharray] == '8, 4'

nil_style = LineStyleMap.style_for(nil)
raise "Expected nil dasharray for nil parent" unless nil_style[:stroke_dasharray].nil?

puts "LineStyleMap verification PASSED!"
exit 0
