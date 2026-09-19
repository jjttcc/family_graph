#!/usr/bin/env ruby
# Dependency Mapper: Maps directory/file dependencies and checks rank violations.
require 'find'
require 'set'
# 1. Load Dependency Specification
RANK_MAP = {}
File.readlines('src/dependency-specification').each do |line|
  next if line.strip.empty? || line.start_with?('#') || line.start_with?('[')
  parts = line.split
  next if parts.size < 2
  RANK_MAP[parts[0]] = parts[1].to_i
end
# Map class names to the file they reside in
CLASS_FILE_MAP = {}
FILE_CLUSTER_MAP = {}
FILE_DEPENDENCIES = Hash.new { |h, k| h[k] = Set.new }
# 2. First Pass: Map classes to files and directories
RANK_MAP.keys.each do |dir|
  path = File.join('src', dir)
  next unless Dir.exist?(path)
  Find.find(path) do |file|
    next unless file.end_with?('.rb')
    FILE_CLUSTER_MAP[file] = dir
    File.readlines(file).each do |line|
      if line =~ /^\s*class\s+(\w+)/
        CLASS_FILE_MAP[$1] = file
      end
    end
  end
end
# 3. Second Pass: Analyze dependencies
FILE_CLUSTER_MAP.keys.each do |file|
  content = File.read(file)
  CLASS_FILE_MAP.each do |class_name, class_file|
    next if class_file == file
    if content.match?(/\b#{class_name}\b/)
      FILE_DEPENDENCIES[file] << class_file
    end
  end
end
# 4. Reporting Logic
def report_violations
  puts "--- Directory Dependency Violation Report ---"
  dir_deps = Hash.new { |h, k| h[k] = Set.new }
  FILE_DEPENDENCIES.each do |file, deps|
    file_dir = FILE_CLUSTER_MAP[file]
    deps.each do |dep|
      dep_dir = FILE_CLUSTER_MAP[dep]
      dir_deps[file_dir] << dep_dir if dep_dir && file_dir != dep_dir
    end
  end
  dir_deps.each do |dir, deps|
    deps.each do |dep|
      rank_dir = RANK_MAP[dir]
      rank_dep = RANK_MAP[dep]
      if rank_dep && rank_dir && rank_dep > rank_dir
        puts "VIOLATION: #{dir} (Rank #{rank_dir}) depends on #{dep} (Rank #{rank_dep})"
        FILE_DEPENDENCIES.each do |file, file_deps|
          next unless FILE_CLUSTER_MAP[file] == dir
          file_deps.each do |dep_file|
            if FILE_CLUSTER_MAP[dep_file] == dep
              puts "  -> #{file} depends on #{dep_file}"
            end
          end
        end
      end
    end
  end
end
target = ARGV[0]
if target.nil?
  report_violations
  puts "\n--- Directory Dependency Report ---"
  dir_deps = Hash.new { |h, k| h[k] = Set.new }
  FILE_DEPENDENCIES.each do |file, deps|
    file_dir = FILE_CLUSTER_MAP[file]
    deps.each do |dep|
      dep_dir = FILE_CLUSTER_MAP[dep]
      dir_deps[file_dir] << dep_dir if dep_dir && file_dir != dep_dir
    end
  end
  dir_deps.each do |dir, deps|
    puts "#{dir} depends on:"
    deps.each { |dep| puts "  -> #{dep}" }
  end
elsif RANK_MAP.key?(target)
  puts "#{target} depends on:"
  dir_deps = Hash.new { |h, k| h[k] = Set.new }
  FILE_DEPENDENCIES.each do |file, deps|
    file_dir = FILE_CLUSTER_MAP[file]
    next unless file_dir == target
    deps.each do |dep|
      dep_dir = FILE_CLUSTER_MAP[dep]
      dir_deps[target] << dep_dir if dep_dir && dep_dir != target
    end
  end
  dir_deps[target].each { |dep| puts "  -> #{dep}" }
elsif FILE_CLUSTER_MAP.key?(target)
  puts "Dependencies of #{target} on other clusters:"
  FILE_DEPENDENCIES[target].each do |dep|
    dep_dir = FILE_CLUSTER_MAP[dep]
    if dep_dir && dep_dir != FILE_CLUSTER_MAP[target]
      puts "  -> #{dep}"
    end
  end
else
  puts "Error: Target '#{target}' not found."
end
