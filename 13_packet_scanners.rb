depths = (ARGV.empty? ? DATA : ARGF).each_line.map { |x|
  x.scan(/\d+/).map(&:to_i)
}.to_h.freeze

periods = depths.map { |k, v| [k, 2 * (v - 1)] }.to_h.freeze

puts periods.select { |k, v| k % v == 0 }.keys.sum { |k| k * depths[k] }

# For a given (depth, period) pair,
# we can determine a forbidden starting time:
# The starting time is NOT congruent to -depth modulo period.
# We combine all these forbidden times by period.
def forbidden_starts(periods)
  periods.group_by(&:last).map { |period, depths|
    [period, depths.map { |depth, _| -depth % period }.sort]
  }.to_h
end

# Expand smaller periods into larger ones, then remove the smaller ones.
# For example, 2 => [1], 8 => [2, 4, 6] would turn into:
# 8 => [2, 4, 6, 1, 3, 5, 7]
def absorb_periods(forbidden_starts)
  periods = forbidden_starts.keys.sort

  periods.each_with_index { |p1, i|
    expand_into = periods[(i + 1)..-1].select { |x| x % p1 == 0 }
    next if expand_into.empty?
    forbidden = forbidden_starts.delete(p1)
    expand_into.each { |p2|
      forbidden_starts[p2] |= (0...p2).select { |p| forbidden.include?(p % p1) }
    }
  }

  forbidden_starts
end

forbidden_starts = absorb_periods(forbidden_starts(periods))

single_openings, other_periods = forbidden_starts.partition { |p, ds|
  ds.size == p - 1
}

# For any periods with only one opening, we can combine them into one big period,
# and this big period also only has one opening!
base, period = single_openings.sort_by(&:first).reverse.reduce([0, 1]) { |(b, p1), (p2, ds)|
  allowed_d = (0...p2).find { |d| !ds.include?(d) }
  b += p1 until b % p2 == allowed_d
  [b, p1.lcm(p2)]
}

puts base.step(by: period).find { |delay|
  # Now we only need to check all other periods.
  other_periods.all? { |p, ds| !ds.include?(delay % p) }
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
