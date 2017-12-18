def run(insts, id, tx, rx)
  regs = Hash.new(0)
  regs[:p] = id
  vals_received = 0
  pc = -1
  resolve = ->(y) { y.is_a?(Integer) ? y : regs[y] }

  while (pc += 1) >= 0 && (inst = insts[pc])
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
        val = nil
        # Oh noes, a spinlock.
        val = rx[vals_received] until val
        vals_received += 1
        regs[inst[1]] = val
      end
    when :jgz
      pc += (resolve[inst[2]] - 1) if resolve[inst[1]] > 0
    else raise "Unknown instruction #{inst}"
    end
  end
end

insts = (ARGV.empty? ? DATA : ARGF).each_line.map { |l|
  inst, *args = l.split
  [inst.to_sym, *args.map { |a| a.match?(/-?\d+/) ? a.to_i : a.to_sym }].freeze
}.freeze

sound = []
puts run(insts, 0, sound, sound)

class Q
  require 'thread'

  def initialize
    @q = []
    @have_elements = ConditionVariable.new
    @lock = Mutex.new
  end

  def <<(x)
    @lock.synchronize {
      @q << x
      @have_elements.signal
    }
  end

  def [](n)
    @lock.synchronize {
      @have_elements.wait(@lock) while n >= @q.size
      @q[n]
    }
  end

  def size
    @q.size
  end
end

send0 = Q.new
send1 = Q.new

t0 = Thread.new { run(insts, 0, send0, send1) }
t1 = Thread.new { run(insts, 1, send1, send0) }
# Couldn't figure out a better way than to busy-wait.
Kernel.sleep(0.01) until t0.status == 'sleep' && t1.status == 'sleep'
puts send1.size

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
