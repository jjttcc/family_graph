# required libraries/tools
require 'ruby_contracts'

class Person
  attr_reader :id, :data, :children
  attr_accessor :spouse_list

  def initialize(id, data = {})
    @id = id
    @data = data
    @spouse_list = [] # Keeping as an array, restricted to 1
    @children = []
  end

  def add_child(child)
    @children << child
  end

  # Queries required by Graph class
  def has_spouse
    !@spouse_list.empty?
  end

  def spouse
    @spouse_list.first
  end

  def add_spouse(person)
    if @spouse_list.size < 1
      @spouse_list << person
    else
      raise "Multiple spouses not supported in current version"
    end
  end

  # Dynamic access for evolving fields
  # Maps underscores to hyphens for seamless YAML lookup (e.g. given_name -> given-name)
  def method_missing(method_name, *args, &block)
    m_str = method_name.to_s
    if @data.key?(m_str) then
      return @data[m_str]
    end

    hyphenated = m_str.gsub('_', '-')
    if @data.key?(hyphenated) then
      return @data[hyphenated]
    end

    super
  end

  def respond_to_missing?(method_name, include_private = false)
    m_str = method_name.to_s
    hyphenated = m_str.gsub('_', '-')
    @data.key?(m_str) || @data.key?(hyphenated) || super
  end
end
