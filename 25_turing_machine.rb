def parse_rule(expect, input)
  zero_or_one = ->(s) { Integer(s[/\d+/]).tap { |i|
    raise "bad #{i}, must be 0 or 1" unless i == 0 || i == 1
  }}

  current = zero_or_one[input.shift]
  raise "unexpected #{current}, wanted #{expect}" if current != expect
  write = zero_or_one[input.shift]
  move = input.shift.include?('right') ? 1 : -1
  state = parse_state(input.shift)

  [write, move, state]
end

def parse_state(line)
  line.chomp[-2].ord - ?A.ord
end

input = (ARGV.empty? ? DATA : ARGF).readlines

state = parse_state(input.shift)
check_after = Integer(input.shift[/\d+/])

states = []

until input.empty?
  raise 'discarded non-empty line' unless input.shift.strip.empty?

  parsing_state = parse_state(input.shift)
  # Assume input comes in order.
  raise "parsing #{parsing_state}, wanted #{states.size}" if parsing_state != states.size
  states << 2.times.map { |i|
    # Assume input comes in order.
    parse_rule(i, input.shift(4))
  }
end

loops = {}

states.each_with_index.to_a.combination(2) { |(va, ka), (vb, kb)|
  [0, 1].each { |bit|
    write_a, move_a, next_a = va[bit]
    write_b, move_b, next_b = vb[bit]
    if move_a == move_b && next_a == kb && next_b == ka
      write = [write_a, write_b]
      loops[[ka, bit]] = [write.freeze, move_a, kb].freeze
      loops[[kb, bit]] = [write.reverse.freeze, move_b, ka].freeze
    end
  }
}

ticker = [0] * (check_after ** 0.5).ceil * 2
pos = ticker.size / 2
n = 0

while n < check_after
  current = ticker[pos] || 0.tap { ticker.concat([0] * ticker.size) }
  if (cycle, move, other = loops[[state, current]])
    original_pos = pos
    original_n = n
    while n < check_after && ticker[pos] == current
      pos += move
      if pos == -1
        pos += ticker.size
        ticker.unshift(*[0] * ticker.size)
      end
      n += 1
    end
    dist = n - original_n
    left = move > 0 ? original_pos : pos + 1
    writes = cycle.cycle.take(dist)
    writes.reverse! if move < 0
    state = other if dist.odd?
    ticker[left, dist] = writes
    next
  end
  ticker[pos], where_to_go, state = states[state][current]
  pos += where_to_go
  if pos < 0
    pos += ticker.size
    ticker.unshift(*[0] * ticker.size)
  end
  n += 1
end

puts ticker.sum

__END__
Begin in state A.
Perform a diagnostic checksum after 12919244 steps.

In state A:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state B.
  If the current value is 1:
    - Write the value 0.
    - Move one slot to the left.
    - Continue with state C.

In state B:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the left.
    - Continue with state A.
  If the current value is 1:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state D.

In state C:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state A.
  If the current value is 1:
    - Write the value 0.
    - Move one slot to the left.
    - Continue with state E.

In state D:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state A.
  If the current value is 1:
    - Write the value 0.
    - Move one slot to the right.
    - Continue with state B.

In state E:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the left.
    - Continue with state F.
  If the current value is 1:
    - Write the value 1.
    - Move one slot to the left.
    - Continue with state C.

In state F:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state D.
  If the current value is 1:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state A.
