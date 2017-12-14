require_relative 'lib/knot_hash'

input = (ARGV.empty? ? DATA : ARGF).read.chomp

puts KnotHash::twist(input.split(?,).map(&:to_i), 1).take(2).reduce(:*)

puts KnotHash::hash(input.bytes + KnotHash::SUFFIX)

__END__
147,37,249,1,31,2,226,0,161,71,254,243,183,255,30,70
