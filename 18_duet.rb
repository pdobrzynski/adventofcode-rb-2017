def run(insts, id, tx, rx)
  regs = Hash.new(0)
  regs[:p] = id
  vals_received = 0
  pc = 0
  resolve = ->(y) { y.is_a?(Integer) ? y : regs[y] }

  -> {
    ran_anything = false

    while pc >= 0 && (inst = insts[pc])
      case inst[0]
      when :snd
        tx << resolve[inst[1]]
      when :set
        regs[inst[1]] = resolve[inst[2]]
      when :add
        regs[inst[1]] += resolve[inst[2]]
      when :mul
        regs[inst[1]] *= resolve[inst[2]]
      when :mod
        regs[inst[1]] %= resolve[inst[2]]
      when :rcv
        if tx.object_id == rx.object_id
          # Part 1!
          return rx[-1] if resolve[inst[1]] != 0
        else
          # Part 2!
          return ran_anything ? :wait : :still_waiting unless (val = rx[vals_received])
          vals_received += 1
          regs[inst[1]] = val
        end
      when :jgz
        pc += (resolve[inst[2]] - 1) if resolve[inst[1]] > 0
      else raise "Unknown instruction #{inst}"
      end

      pc += 1
      ran_anything = true
    end

    :finished
  }
end

insts = (ARGV.empty? ? DATA : ARGF).each_line.map { |l|
  inst, *args = l.split
  [inst.to_sym, *args.map { |a| a.match?(/-?\d+/) ? a.to_i : a.to_sym }].freeze
}.freeze

sound = []
puts run(insts, 0, sound, sound)[]

send = [[], []]
runners = [0, 1].map { |id| run(insts, id, send[id], send[1 - id]) }
other_was_waiting = false
puts 0.step { |n|
  status = runners[n % 2][]
  if status == :still_waiting && other_was_waiting
    # Deadlocked.
    break send[1].size
  end
  other_was_waiting = status == :still_waiting
}

__END__
set i 31
set a 1
mul p 17
jgz p p
mul a 2
add i -1
jgz i -2
add a -1
set i 127
set p 622
mul p 8505
mod p a
mul p 129749
add p 12345
mod p a
set b p
mod b 10000
snd b
add i -1
jgz i -9
jgz a 3
rcv b
jgz b -1
set f 0
set i 126
rcv a
rcv b
set p a
mul p -1
add p b
jgz p 4
snd a
set a b
jgz 1 3
snd b
set f 1
add i -1
jgz i -11
snd a
jgz f -16
jgz a -19
