#!/usr/bin/env ruby

drupal_version = ARGV[0] || '8.x'

if drupal_version == '8.x'
  log_args = ARGV[1] || '--since=2011-03-09'
else
  log_args = ARGV[1] || ''
end
  


Encoding.default_external = Encoding::UTF_8
require 'erb'
require 'yaml'
require 'json'

name_mappings = YAML::load_file('./name_mappings.yml')
contributors = Hash.new(0)
git_command = 'git --git-dir=drupal_' + drupal_version + '/.git --work-tree=drupal log ' +  drupal_version + ' ' +  log_args + ' -s --format=%s'


%x[#{git_command}].split("\n").each do |m|
  m.gsub(/\-/, '_').scan(/\s(?:by\s?)([[:word:]\s,.|]+):/i).each do |people|
    people[0].split(/[,|]/).each do |p|
      name = p.strip.downcase
      contributors[name_mappings[name] || name] += 1 unless p.nil?
    end
  end
end

sum = contributors.values.reduce(:+).to_f
contributors = Hash[contributors.sort_by {|k, v| v }.reverse]


output = {
  :date => Time.new,
  :count => contributors.length,
  :graph => {
    :one => contributors.select {|k,v| v < 2}.length,
    :twoTen => contributors.select {|k,v| (v > 1 && v < 11) }.length,
    :TenOver => contributors.select {|k,v| v > 10}.length
  },
  :contributors => contributors
}

puts output.to_json
