module DebugLogger

  DEBUG_FILE = '/tmp/family_graph_debug.log'

  def self.log(message, separaror = ' ')
    if ! message.is_a?(Array) then
      message = [message]
    end
    File.open(DEBUG_FILE, 'a') { |f| f.puts(message.join(separaror)) }
  end

end
