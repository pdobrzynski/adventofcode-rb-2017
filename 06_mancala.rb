input = (ARGV.empty? ? DATA : ARGF).read.split.map(&:to_i)

seen = {input.dup => 0}
puts 1.step { |n|
  max = input.max
  start = input.index(max)
  input[start] = 0
  max.times { |i| input[(start + 1 + i) % input.size] += 1 }
  break [n, n - seen[input]] if seen.has_key?(input)
  seen[input.dup] = n
}

__END__
2	8	8	5	4	2	3	1	5	5	1	2	15	13	5	14
