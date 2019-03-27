require 'bundler'
require 'tty-table'

gem_names = ARGV
if gem_names.empty?
  puts "Usage: ruby #{$0} [Gem name] [Gem name] ..."
  return
end

versions = {}

Dir.each_child('../') do |f|
  dir_name = '../' + f
  next unless File.directory?(dir_name)

  file_name = dir_name + '/Gemfile.lock'

  next unless File.exist?(file_name)

  parser = Bundler::LockfileParser.new(Bundler.read_file(file_name))
  parser.specs.each do |spec|
    if gem_names.include?(spec.name)
      index = gem_names.index(spec.name)
      versions[f] ||= []
      versions[f][index] = spec.version.to_s
    end
  end
end

versions_array = []
versions.each do |k, v|
  numbers = v
  range = numbers.length..gem_names.length-1
  numbers.fill(nil, range)
  versions_array << [k] + v
end

header = [nil] + gem_names
table = TTY::Table.new(header, versions_array)
print table.render(:ascii)