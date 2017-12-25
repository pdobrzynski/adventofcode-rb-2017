def grid(s, pad_size, clean, infected)
  grid = Array.new(s.size + pad_size * 2) { Array.new(s.size + pad_size * 2, clean) }
  c = {?# => infected, ?. => clean}
  s.each_with_index { |row, y|
    grid[pad_size + y][pad_size, row.size] = row.each_char.map(&c)
  }
  grid
end

def infects(s, n, states)
  # Using Hash[Symbol => Symbol] slows by about 20%,
  # so we translate to integers.
  infected = states.index(:infected)
  clean = states.index(:clean)
  flagged = states.index(:flagged)

  next_state = (0...states.size).to_a.rotate(1).freeze

  # cache key = nine squares, facing
  # (could do better by making it facing-independent)
  # cache key => [steps to advance, infects, nine squares, facing, where to move]
  cache = {}

  t = Time.now
  a = [(0...states.size).to_a] * 9
  a[0].product(*a[1..-1]).each { |neighbourhood|
    cache_key = neighbourhood.reduce(0) { |acc, c|
      acc << 2 | c
    }
    [[-1, 0], [1, 0], [0, -1], [0, 1]].each { |dy0, dx0|
      g = neighbourhood.each_slice(3).to_a
      cn = 0
      dy = dy0
      dx = dx0
      infects = 0
      x = 1
      y = 1
      while (0..2).cover?(x) && (0..2).cover?(y)
        cn += 1
        old_status = g[y][x]
        new_status = next_state[old_status]
        infects += 1 if new_status == infected
        # Strangely, case/when slows by about 30%?!
        # Maybe Integer#=== is expensive?
        if old_status == clean
          dy, dx = [-dx, dy]
        elsif old_status == infected
          dy, dx = [dx, -dy]
        elsif old_status == flagged
          dy *= -1
          dx *= -1
        end
        g[y][x] = new_status
        y += dy
        x += dx
      end
      cache[cache_key << 4 | (dy0 + 1) << 2 | (dx0 + 1)] = [
        cn,
        infects,
        g.flatten,
        [dy, dx],
        [y - 1, x - 1],
      ]
    }
  }
  STDERR.puts "cache ready in #{Time.now - t}"

  # No I'm not actually sure this padding size is provably correct
  # But instead doing a Hash[Coordinate => State] slows us by 5x-6x.
  g = grid(s, (n ** 0.5 / states.size).ceil, clean, infected)
  y = x = g.size / 2
  dy = -1
  dx = 0
  infects = 0
  scans = 0
  saves = 0

  i = 0
  while i < n
    cache_key = [-1, 0, 1].reduce(0) { |acc, cdy|
      row = g[y + cdy]
      acc << 6 | [-1, 0, 1].reduce(0) { |row_acc, cdx|
        row_acc << 2 | row[x + cdx]
      }
    } << 4 | (dy + 1) << 2 | (dx + 1)
    steps_to_skip, infects_to_add, cached_grid, new_dir, delta_pos = cache.fetch(cache_key)
    # Can only use cache if we won't go over number of steps.
    if i + steps_to_skip < n
      j = 0
      [-1, 0, 1].each { |cdy|
        row = g[y + cdy]
        [-1, 0, 1].each { |cdx|
          row[x + cdx] = cached_grid[j]
          j += 1
        }
      }

      i += steps_to_skip
      saves += steps_to_skip
      scans += 9
      infects += infects_to_add
      dy, dx = new_dir
      y += delta_pos[0]
      x += delta_pos[1]
      next
    end

    old_status = g[y][x]
    new_status = next_state[old_status]
    infects += 1 if new_status == infected
    # Strangely, case/when slows by about 30%?!
    # Maybe Integer#=== is expensive?
    if old_status == clean
      dy, dx = [-dx, dy]
    elsif old_status == infected
      dy, dx = [dx, -dy]
    elsif old_status == flagged
      dy *= -1
      dx *= -1
    end
    g[y][x] = new_status
    y += dy
    x += dx
    i += 1
  end

  STDERR.puts("For #{scans} scans we saved #{saves} iterations")

  infects
end

input = (ARGV.empty? ? DATA : ARGF).each_line.map { |l| l.chomp.freeze }.freeze

puts infects(input, 10 ** 4, %i(clean infected))
puts infects(input, 10 ** 7, %i(clean weakened infected flagged))

__END__
.###.#.#####.##.#...#....
..####.##.##.#..#.....#..
.#####.........#####..###
#.#..##..#.###.###.#.####
.##.##..#.###.###...#...#
#.####..#.#.##.##...##.##
..#......#...#...#.#....#
###.#.#.##.#.##.######..#
###..##....#...##....#...
###......#..#..###.#...#.
#.##..####.##..####...##.
###.#.#....######.#.###..
.#.##.##...##.#.#..#...##
######....##..##.######..
##..##.#.####.##.###.#.##
#.###.#.##....#.##..####.
#.#......##..####.###.#..
#..###.###...#..#.#.##...
#######..#.....#######..#
##..##..#..#.####..###.#.
..#......##...#..##.###.#
....##..#.#.##....#..#.#.
..#...#.##....###...###.#
#.#.#.#..##..##..#..#.##.
#.####.#......#####.####.
