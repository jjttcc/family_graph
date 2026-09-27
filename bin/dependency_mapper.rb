#!/usr/bin/env ruby
# Dependency Mapper: Maps directory/file dependencies and checks rank violations.

require 'find'
require 'set'

# Dynamically determine the project root (assuming script is in bin/)
ROOT = File.expand_path('..', __dir__)
$status = 0

# Helper to get path relative to current working directory
def relative_path(full_path)
  Pathname.new(full_path).relative_path_from(Pathname.new(Dir.pwd)).to_s
end

# 1. Load Dependency Specification
RANK_MAP = {}
spec_path = File.join(ROOT, 'src', 'dependency-specification')
File.readlines(spec_path).each do |line|
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
  path = File.join(ROOT, 'src', dir)
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
        $status += 1
        puts "VIOLATION: #{dir} (Rank #{rank_dir}) depends on #{dep} " +
          "(Rank #{rank_dep})"
        FILE_DEPENDENCIES.each do |file, file_deps|
          next unless FILE_CLUSTER_MAP[file] == dir
          file_deps.each do |dep_file|
            if FILE_CLUSTER_MAP[dep_file] == dep
              puts "  -> #{relative_path(file)} depends on " +
                "#{relative_path(dep_file)}"
            end
          end
        end
      end
    end
  end
end

# Find absolute file path
def find_absolute_file(target)
  # Check if it's already an absolute path
  return target if File.exist?(target) && Pathname.new(target).absolute?
  
  # Try relative to CWD
  abs = File.expand_path(target, Dir.pwd)
  return abs if File.exist?(abs)

  # Try relative to project root
  abs = File.join(ROOT, target)
  return abs if File.exist?(abs)

  # Fallback: fuzzy match
  FILE_CLUSTER_MAP.keys.find { |f| f.end_with?(target) }
end

require 'pathname'

target_arg = ARGV[0]
if target_arg.nil?
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
elsif RANK_MAP.key?(target_arg)
  puts "#{target_arg} depends on:"
  dir_deps = Hash.new { |h, k| h[k] = Set.new }
  FILE_DEPENDENCIES.each do |file, deps|
    file_dir = FILE_CLUSTER_MAP[file]
    next unless file_dir == target_arg
    deps.each do |dep|
      dep_dir = FILE_CLUSTER_MAP[dep]
      dir_deps[target_arg] << dep_dir if dep_dir && dep_dir != target_arg
    end
  end
  dir_deps[target_arg].each { |dep| puts "  -> #{dep}" }
else
  found_file = find_absolute_file(target_arg)
  if found_file
    puts "Dependencies of #{relative_path(found_file)} on other clusters:"
    FILE_DEPENDENCIES[found_file].each do |dep|
      dep_dir = FILE_CLUSTER_MAP[dep]
      if dep_dir && dep_dir != FILE_CLUSTER_MAP[found_file]
        puts "  -> #{relative_path(dep)}"
      end
    end
  else
    puts "Error: Target '#{target_arg}' not found."
  end
end

exit $status
