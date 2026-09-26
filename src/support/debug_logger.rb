# Logging utilities for debugging execution paths and data structures.
module DebugLogger

  DEBUG_FILE = '/tmp/family_graph_debug.log'

  # Logs one or more messages (or an array of messages) to the debug log file.
  def log(*messages, separator: ' ')
    if messages.size == 1 && messages.first.is_a?(Array) then
      items = messages.first
    else
      items = messages
    end
    File.open(DEBUG_FILE, 'a') { |f| f.puts(items.join(separator)) }
  end

end
