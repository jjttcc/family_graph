# vim: ts=2 sw=2 expandtab
require 'ruby_contracts'
require 'family_constants'

# Domain-level utility methods for querying graph domain entities.
module DomainTools
  include Contracts::DSL

  public

  # Returns root Person objects based on options (explicit ROOT_IDS or is_root).
  pre :people_valid do |people| people.is_a?(Enumerable) end
  pre :options_valid do |options| options.is_a?(Enumerable) end
  post :roots_valid do |result|
    result.is_a?(Array) && result.all? { |p| p.is_a?(Person) }
  end
  def self.roots(people, options)
    root_ids = options[ROOT_IDS]
    if root_ids then
      root_ids.map do |id|
        people[id]
      end
    else
      people.values.select do |person|
        person.is_root
      end
    end
  end

end
