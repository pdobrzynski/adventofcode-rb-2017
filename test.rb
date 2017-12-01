require 'time'

dir = __dir__

all_good = true

to_test = ARGV.empty? ? 1..25 : ARGV.map(&:to_i)

to_test.map { |i|
  id = i.to_s.rjust(2, ?0)
  commands = Dir.glob("#{dir}/#{id}*.rb").map { |ruby_script|
    "ruby #{ruby_script} | diff -u - #{dir}/expected_output/#{id}"
  }
  Thread.new {
    commands.each { |command|
      start_time = Time.now
      if system(command)
        puts "#{id} passed in #{Time.now - start_time}"
      else
        puts "#{id} failed in #{Time.now - start_time}"
        puts command
        all_good = false
      end
    }
  }
}.each(&:join)

Kernel.exit(all_good ? 0 : 1)
