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
raise "Expected stroke-width=\"2\" and dash_array=\"4, 2\" for SPOUSE" unless spouse_style.to_svg_attributes == 'stroke-width="2" stroke-dasharray="4, 2"'

bio_style = LineStyleMap.style_for(BIOLOGICAL)
raise "Expected stroke-width=\"1\" for BIOLOGICAL" unless bio_style.to_svg_attributes == 'stroke-width="1"'

adoptive_style = LineStyleMap.style_for(ADOPTIVE)
raise "Expected stroke-width=\"3\" for ADOPTIVE" unless adoptive_style.stroke_width == 3
raise "Expected correct attributes for ADOPTIVE" unless adoptive_style.to_svg_attributes == 'stroke-width="3" stroke-dasharray="0, 10" stroke-linecap="round"'

assumed_style = LineStyleMap.style_for(ASSUMED)
raise "Expected stroke-dasharray=\"8, 4\" for ASSUMED" unless assumed_style.to_svg_attributes == 'stroke-width="1" stroke-dasharray="8, 4"'

puts "LineStyleMap verification PASSED!"
exit 0
