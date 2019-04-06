# frozen_string_literal: true

# main method - just check to make sure we
require 'flamegraph'
require_relative 'naive'
html = Flamegraph.generate('graph.html') do
  if ARGV.size != 1
    puts 'Usage: ruby verifier.rb <name_of_file>'
    puts '       name_of_file = name of file to verify'
    return
  elsif !File.file?(ARGV[0])
    puts 'Error: File was not found.'
    return
  end
  
  # the verifier object depends on what file I've included at the top
  v = Verifier.new(ARGV[0])
  v.process
  v.put_result
end
