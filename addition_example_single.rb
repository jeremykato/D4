a = Array.new(50000000) { rand(65336) }
b = 0

time = Time.now

i = 0
while i < 50000000
  b = (b + a[i] ) % 65336
  i += 1
end


time = (Time.now - time) * 1000.0

puts 'Result: '
puts b
puts 'Time taken: '
puts time