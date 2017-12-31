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

START_STATE = parse_state(input.shift)
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

cache = {}
BLOCK_SIZE = 7
BLOCK_RADIUS = BLOCK_SIZE / 2

(0...(2 ** BLOCK_SIZE)).each { |x|
  bits = (0...BLOCK_SIZE).map { |bit_i| x & (1 << (BLOCK_SIZE - 1 - bit_i)) != 0 ? 1 : 0 }
  states.each_index { |start_state|
    n = 0
    state = start_state
    ticker = bits.dup
    pos = BLOCK_RADIUS
    while pos >= 0 && (current = ticker[pos])
      ticker[pos], where_to_go, state = states[state][current]
      pos += where_to_go
      n += 1
    end
    raise 'conflict' if cache.has_key?(start_state << BLOCK_SIZE | x)
    cache[start_state << BLOCK_SIZE | x] = [state, ticker.freeze, pos - BLOCK_RADIUS, n].freeze
  }
}

ticker = [0] * (check_after ** 0.5).ceil * 2
pos = ticker.size / 2
state = START_STATE
n = 0

scans = 0
saves = 0

while n < check_after
  x = (-BLOCK_RADIUS..BLOCK_RADIUS).reduce(0) { |acc, dp| acc << 1 | (
    ticker[pos + dp] || 0.tap { ticker.concat([0] * ticker.size) }
  )}
  new_state, new_bits, delta_pos, delta_n = cache[state << BLOCK_SIZE | x]
  if n + delta_n < check_after
    ticker[pos - BLOCK_RADIUS, BLOCK_SIZE] = new_bits
    pos += delta_pos
    n += delta_n
    scans += BLOCK_SIZE
    saves += delta_n
    state = new_state
  else
    ticker[pos], where_to_go, state = states[state][ticker[pos]]
    pos += where_to_go
    n += 1
  end

  if pos - BLOCK_RADIUS < 0
    pos += ticker.size
    ticker.unshift(*[0] * ticker.size)
  end
end

STDERR.puts "With #{scans} scans, saved #{saves} iterations."
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
