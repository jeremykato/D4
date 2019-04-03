# native ruby won't let us make massive arrays, so ours is 1/10th of the size
size = 50000000
a = Array.new(size) { rand(65336) }
b = 0

10.times do # do ten times to make up for array size
  i = 0
  while i < size
    b = (b + a[i] ) % 65336
    i += 1
  end
end

puts 'Result: ' + b.to_s