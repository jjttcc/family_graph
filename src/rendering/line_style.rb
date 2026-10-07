require 'ruby_contracts'

# frozen_string_literal: true

# Represents the stroke and style attributes of a relationship line.
class LineStyle
  include Contracts::DSL

  public

  attr_reader :stroke_width, :dash_array, :stroke_linecap, :description

  def initialize(stroke_width:, dash_array: nil, stroke_linecap: nil,
                 description:)
    @stroke_width   = stroke_width
    @dash_array     = dash_array
    @stroke_linecap = stroke_linecap
    @description    = description
  end

  def to_svg_attributes
    attrs = []
    attrs << "stroke-width=\"#{@stroke_width}\""
    attrs << "stroke-dasharray=\"#{@dash_array}\"" if @dash_array
    attrs << "stroke-linecap=\"#{@stroke_linecap}\"" if @stroke_linecap
    attrs.join(' ')
  end

end
