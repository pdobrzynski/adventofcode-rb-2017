require 'json'
require 'time'

people = ARGV.flat_map { |a| JSON.parse(File.read(a))['members'].values }

max_day = people.flat_map { |v| v['completion_day_level'].keys }.map(&:to_i).max
longest_name = people.map { |v| v['name'] || v['id'] }.map(&:size).max

(1..max_day).each { |day|
  (1..2).each { |part|
    completing_people = people.map { |p|
      ts = p.dig('completion_day_level', day.to_s, part.to_s, 'get_star_ts')
      ts && [p['name'] || p['id'], Time.parse(ts)]
    }.compact.to_h
    puts "Day #{day} Part #{part}:"
    fmt = "%#{longest_name}s %s %d"
    completing_people.sort_by(&:last).each_with_index { |(p, t), i|
      puts fmt % [p, t, people.size - i]
    }
    puts
  }
}
