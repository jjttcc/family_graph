module DebugLogger
  DEBUG_FILE = '/tmp/family_graph_debug.log'
  def self.log(message)
    File.open(DEBUG_FILE, 'a') { |f| f.puts(message) }
  end
end
