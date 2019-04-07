# frozen_string_literal: true

# main method - just check to make sure we
require_relative 'parallel_engine'
if ARGV.size != 1
  puts 'Usage: ruby verifier.rb <name_of_file>'
  puts '       name_of_file = name of file to verify'
  return
elsif !File.file?(ARGV[0])
  puts 'Error: File was not found.'
  return
end


Parallel.map([0,1,2,3], in_threads: 4) do |p|
# the verifier object depends on what file I've included at the top
  v = Verifier.new(IO.readlines(ARGV[0]), p)
  v.process
  if !v.success?
    v.put_result
  elsif p == 2
    v.put_result
  end
end