require_relative 'lib/knot_hash'
require_relative 'lib/union_find'

GRID = 128

input = ARGV.first || 'hxtvlmkl'

NIBBLE = (0...16).map { |x|
  bits = [8, 4, 2, 1].map { |bit| x & bit != 0 }
  [x.to_s(16), bits.freeze]
}.to_h.freeze

grid = (0...GRID).map { |n|
  KnotHash::hash(
    "#{input}-#{n}".bytes + KnotHash::SUFFIX
  ).each_char.flat_map(&NIBBLE)
}

puts grid.sum { |row| row.count(true) }

DIR = [
  [1, 0],
  [0, 1],
].map(&:freeze).freeze

used = grid.flat_map.with_index { |row, y|
  row.map.with_index { |cell, x| [y, x] if cell }.compact
}

uf = UnionFind.new(used)

used.each { |x|
  r, c = x
  DIR.map { |dy, dx| [r + dy, c + dx] }.select { |n|
    n.all? { |nn| nn >= 0 } && grid.dig(*n)
  }.each { |n| uf.union(x, n) }
}

puts used.map { |x| uf.find(x) }.uniq.size
