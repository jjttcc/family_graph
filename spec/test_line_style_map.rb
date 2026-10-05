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
require 'family_constants'

puts "Verifying LineStyleMap..."

spouse_style = LineStyleMap.style_for(SPOUSE)
raise "Expected stroke-dasharray=\"8, 4\" for SPOUSE" unless spouse_style == 'stroke-dasharray="8, 4"'

bio_style = LineStyleMap.style_for(BIOLOGICAL)
raise "Expected empty string for BIOLOGICAL" unless bio_style == ''

adoptive_style = LineStyleMap.style_for(ADOPTIVE)
raise "Expected stroke-dasharray=\"1, 4\" stroke-linecap=\"round\" for ADOPTIVE" unless adoptive_style == 'stroke-dasharray="1, 4" stroke-linecap="round"'

assumed_style = LineStyleMap.style_for(ASSUMED)
raise "Expected stroke-dasharray=\"8, 4\" for ASSUMED" unless assumed_style == 'stroke-dasharray="8, 4"'

puts "LineStyleMap verification PASSED!"
exit 0
