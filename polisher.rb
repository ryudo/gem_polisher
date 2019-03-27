require 'bundler'
require 'tty-table'

gem_names = ARGV
if gem_names.empty?
  puts "Usage: ruby #{$0} [Gem name] [Gem name] ..."
  return
end

versions = {}
base_dir = '../'
Dir.each_child(base_dir) do |repo_dir|
  dir_name = base_dir + repo_dir
  next unless File.directory?(dir_name)

  file_name = dir_name + '/Gemfile.lock'

  next unless File.exist?(file_name)

  parser = Bundler::LockfileParser.new(Bundler.read_file(file_name))
  parser.specs.each do |spec|
    if gem_names.include?(spec.name)
      index = gem_names.index(spec.name)
      versions[repo_dir] ||= []
      versions[repo_dir][index] = spec.version.to_s
    end
  end
end

versions_array = []
versions.each do |repo_name, v|
  numbers = v
  range = numbers.length..gem_names.length-1
  numbers.fill(nil, range)
  versions_array << [repo_name] + numbers
end

header = [nil] + gem_names
table = TTY::Table.new(header, versions_array)
print table.render(:ascii)