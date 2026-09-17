#!/bin/env ruby
# Set up environment variables for famili_graph ruby application.

FG_ROOT=Dir.pwd
RUBYLIB='RUBYLIB'

def set_rubylib(args)
  if args.count > 0 then
    $LOAD_PATH << "#{FG_ROOT}/#{args[0]}"
    args.shift
    args.each do |a|
      $LOAD_PATH << "#{FG_ROOT}/#{a}"
    end
  end
end

dirlist = %w[util
graph_logic
management
data
support
domain
main
geometry
layout
core
construction
rendering]

set_rubylib(dirlist)
