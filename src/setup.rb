#!/bin/env ruby
# Set up environment variables for famili_graph ruby application.
require 'debug'

root_env_var = 'FG_ROOT'
ROOT_PATH = ENV[root_env_var]
if ROOT_PATH == nil then
  raise "#{root_env_var} environment variable is not set."
end

def set_rubylib(args)
  if args.count > 0 then
    $LOAD_PATH << "#{ROOT_PATH}/#{args[0]}"
    args.shift
    args.each do |a|
      $LOAD_PATH << "#{ROOT_PATH}/#{a}"
    end
  end
end

dirlist = %w[
util
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
util
rendering
]

set_rubylib(dirlist)
