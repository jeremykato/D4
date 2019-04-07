require 'parallel'

x = Parallel.map(0..10_000_000, in_processes: 3) do |l|
  puts l
end