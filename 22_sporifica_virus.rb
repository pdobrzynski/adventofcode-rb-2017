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

  # No I'm not actually sure this padding size is provably correct
  # But instead doing a Hash[Coordinate => State] slows us by 5x-6x.
  g = grid(s, (n ** 0.5 / states.size).ceil, clean, infected)
  y = x = g.size / 2
  dy = -1
  dx = 0
  infects = 0

  next_state = (0...states.size).to_a.rotate(1).freeze

  # cache key = nine squares, facing
  # (could do better by making it facing-independent)
  # cache key => [i at entrance, where it is]
  in_progress_cache = {}
  # cache key => [steps to advance, nine squares, facing, where to move]
  cache = {}

  hit = 0
  miss = 0

  i = 0
  while i < n
    cache_key = [-1, 0, 1].reduce(0) { |acc, cdy|
      row = g[y + cdy]
      acc << 6 | [-1, 0, 1].reduce(0) { |row_acc, cdx|
        begin
        row_acc << 2 | row[x + cdx]
        rescue => e
        puts "Row is #{row.size}, you want #{x + cdx}"
        puts e
        end
      }
    } << 4 | (dy + 1) << 2 | (dx + 1)
    if cache.has_key?(cache_key)
      cached = cache[cache_key]
      steps_to_skip = cached[9]
      # Can only use cache if we won't go over number of steps.
      if i + steps_to_skip < n
        j = 0
        [-1, 0, 1].each { |cdy|
          row = g[y + cdy]
          [-1, 0, 1].each { |cdx|
            row[x + cdx] = cached[j]
            j += 1
          }
        }

        i += steps_to_skip
        infects += cached[10]
        dy = cached[11]
        dx = cached[12]
        y += cached[13]
        x += cached[14]
        hit += 1
        # Moving multiple steps might mess up cache calculation.
        in_progress_cache.clear
        next
      end
    elsif !in_progress_cache.has_key?(cache_key)
      in_progress_cache[cache_key] = [i, infects, y, x]
    end
    miss += 1

    in_progress_cache.select { |k, (_, _, cy, cx)|
      (y - cy).abs >= 2 || (x - cx).abs >= 2
    }.each { |k, (ci, cinf, cy, cx)|
      cache[k] = [-1, 0, 1].flat_map { |cdy|
        row = g[cy + cdy]
        [-1, 0, 1].map { |cdx|
          row[cx + cdx]
        }
      } + [i - ci, infects - cinf, dy, dx, y - cy, x - cx]
      in_progress_cache.delete(k)
    }

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

  STDERR.puts "#{hit} hits, #{miss} miss"

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
