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

# I'll not use the entire word; in Ruby 2.3 1 << 62 is Bignum.
BLOCK_SIZE = 0.size * 8 - 3

ticker = [0] * ((check_after ** 0.5).ceil * 2 / BLOCK_SIZE)

pos = ticker.size * BLOCK_SIZE / 2
block_i, block_pos = pos.divmod(BLOCK_SIZE)
block = 0

check_after.times {
  bit = 1 << block_pos

  write, where_to_go, state = states[state][block[block_pos]]
  if write == 0
    block &= ~bit
  else
    block |= bit
  end

  block_pos += where_to_go
  if block_pos < 0
    ticker[block_i] = block
    block_pos += BLOCK_SIZE
    block_i -= 1
    if block_i == -1
      block_i += ticker.size
      ticker.unshift(*[0] * ticker.size)
    end
    block = ticker[block_i]
  elsif block_pos == BLOCK_SIZE
    ticker[block_i] = block
    block_pos = 0
    block_i += 1
    ticker.concat([0] * ticker.size) if block_i == ticker.size
    block = ticker[block_i]
  end
}

ticker[block_i] = block

puts ticker.sum { |x| x.digits(2).count(1) }

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
