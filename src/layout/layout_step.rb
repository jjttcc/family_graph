# vim: ts=2 sw=2 expandtab
require 'ruby_contracts'

# The abstract ancestor class for all layout processing steps.
# Concrete steps must implement the execute method.
class LayoutStep
  include Contracts::DSL

  # Executes the layout transformation using the context.
  # @param context [LayoutContext]
  pre :context_valid do |context| !context.nil? end
  def execute(context)
    raise NotImplementedError, "#{self.class} must implement #execute"
  end

end
