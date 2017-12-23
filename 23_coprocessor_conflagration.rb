require 'prime'

def run(insts, debug: true)
  regs = Hash.new(0)
  regs[:a] = debug ? 0 : 1
  pc = -1
  muls = 0
  resolve = ->(y) { y.is_a?(Integer) ? y : regs[y] }

  while (pc += 1) >= 0 && (inst = insts[pc])
    if !debug && pc == 8
      regs[:f] = Prime.prime?(regs[:b]) ? 1 : 0
      pc += 15
      next
    end

    case inst[0]
    when :sub
      regs[inst[1]] -= resolve[inst[2]]
    when :set
      regs[inst[1]] = resolve[inst[2]]
    when :mul
      muls += 1
      regs[inst[1]] *= resolve[inst[2]]
    when :jnz
      pc += (resolve[inst[2]] - 1) if resolve[inst[1]] != 0
    else raise "Unknown instruction #{inst}"
    end
  end

  debug ? muls : regs[:h]
end

insts = (ARGV.empty? ? DATA : ARGF).each_line.map { |l|
  inst, *args = l.split
  [inst.to_sym, *args.map { |a| a.match?(/-?\d+/) ? a.to_i : a.to_sym }].freeze
}.freeze

[true, false].each { |debug| puts run(insts, debug: debug) }

__END__
set b 84
set c b
jnz a 2
jnz 1 5
mul b 100
sub b -100000
set c b
sub c -17000
set f 1
set d 2
set e 2
set g d
mul g e
sub g b
jnz g 2
set f 0
sub e -1
set g e
sub g b
jnz g -8
sub d -1
set g d
sub g b
jnz g -13
jnz f 2
sub h -1
set g b
sub g c
jnz g 2
jnz 1 3
sub b -17
jnz 1 -23
