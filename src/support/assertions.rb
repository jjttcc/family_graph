# vim: ts=2 sw=2 expandtab

# Provides Eiffel-style check assertions for runtime verification.
module Assertions

  # Asserts that the given block evaluates to true, raising an error if false.
  def check(message = "Assertion failed", &block)
    if !yield then
      raise message
    end
  end

end
