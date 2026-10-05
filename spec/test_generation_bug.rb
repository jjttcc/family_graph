#!/usr/bin/env ruby

root = 'FG_ROOT'
root_path = ENV[root]
setup_path = "#{root_path}/setup.rb"
require setup_path
require 'data_loader'
require 'hierarchy_analyzer_step'
require 'layout_context'
require 'coordinates'

# Create a temporary yaml test file with the user's records
yaml_content = <<~YAML
  thomas_stevens_1808:
    given-name: Thomas
    surname: Stevens
    birth-date: 1808-01-01

  francis_thomas_stevens_1854:
    given-name: Francis Thomas
    surname: Stevens
    birth-date: 1854-05-31
    death-date: 1923-10-12
    father: thomas_stevens_1808

  martha_stark_westcott_1849:
    given-name: Martha
    surname: Westcott
    birth-date: 1849-01-01

  walter_westcott_stevens_1872:
    given-name: Walter
    surname: Stevens
    original-surname: Westcott
    birth-date: 1872-02-21
    death-date: 1963-12-23
  <TAB>mother: martha_stark_westcott_1849
  <TAB>assumed-father: francis_thomas_stevens_1854
YAML
yaml_content = yaml_content.gsub('<TAB>', '  ')

temp_file = '/tmp/stevens_test.yaml'
File.write(temp_file, yaml_content)

people = DataLoader.load(temp_file)
puts "Loaded #{people.size} people."

context = LayoutContext.new(people, [], Coordinates.new, { TRAVERSAL => DESCENDANT })
HierarchyAnalyzerStep.new(context).execute

people.each_value do |p|
  puts "Person: #{p.id} (#{p.given_name} #{p.surname}), Generation: #{p.generation}"
end
