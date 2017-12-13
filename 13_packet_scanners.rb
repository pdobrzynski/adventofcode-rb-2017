depths = (ARGV.empty? ? DATA : ARGF).each_line.map { |x|
  x.scan(/\d+/).map(&:to_i)
}.to_h.freeze

periods = depths.map { |k, v| [k, 2 * (v - 1)] }.to_h.freeze

puts periods.select { |k, v| k % v == 0 }.keys.sum { |k| k * depths[k] }

puts 0.step.find { |delay|
  periods.all? { |k, v| (k + delay) % v != 0 }
}

__END__
0: 3
1: 2
2: 6
4: 4
6: 4
8: 8
10: 9
12: 8
14: 5
16: 6
18: 8
20: 6
22: 12
24: 6
26: 12
28: 8
30: 8
32: 10
34: 12
36: 12
38: 8
40: 12
42: 12
44: 14
46: 12
48: 14
50: 12
52: 12
54: 12
56: 10
58: 14
60: 14
62: 14
64: 14
66: 17
68: 14
72: 14
76: 14
80: 14
82: 14
88: 18
92: 14
98: 18
