# --------------------------------------------------------------------
# based on http://weblog.jamisbuck.org/2010/12/27/maze-generation-recursive-backtracking
# --------------------------------------------------------------------

# --------------------------------------------------------------------
# Recursive backtracking algorithm for maze generation. Requires that
# the entire maze be stored in memory, but is quite fast, easy to
# learn and implement, and (with a few tweaks) gives fairly good mazes.
# Can also be customized in a variety of ways.
# --------------------------------------------------------------------

# --------------------------------------------------------------------
# 1. Allow the maze to be customized via command-line parameters
# --------------------------------------------------------------------

# ARGV is an array created to hold the command-line params
# It is created regardless of whether or not there are actual parameters.

# set width to the first argument or 10 if it is ommitted, and convert to an integer
width  = (ARGV[0] || 10).to_i
# set the height equal to the second argument or width if it is ommitted, and convert to an integer
height = (ARGV[1] || width).to_i
# set the seed equal to the third paramter or generate a random number if it is ommited, and convert to an integer
# the random number will have a max value of 0xFFFFFFFF, which is the largest 32 bit number represented in HEX
seed   = (ARGV[2] || rand(0xFFFF_FFFF)).to_i

# tell the random number generator about the seed
# kinda unsure how this works relative to the rand call above
srand(seed)

# create an array of other equally sized arrays
grid = Array.new(height) { Array.new(width, 0) }

# --------------------------------------------------------------------
# 2. Set up constants to aid with describing the passage directions
# --------------------------------------------------------------------

N, S, E, W = 1, 2, 4, 8								# parallel assignment
DX         = { E => 1, W => -1, N =>  0, S => 0 }	# hash
DY         = { E => 0, W =>  0, N => -1, S => 1 }	# hash
OPPOSITE   = { E => W, W =>  E, N =>  S, S => N }	# hash

# --------------------------------------------------------------------
# 3. The recursive-backtracking algorithm itself
# --------------------------------------------------------------------

# cx = starting x coordinate in the grid array
# cy = starting y coordinate in the grid array
# grid = the actual array of arrays representing our grid

def carve_passages_from(cx, cy, grid)
  
  # This creates a random direction order to try. We don't want to favor any particular direction
  # Not eactly sure why we use sort_by instead of sort -- probably because sort can't be randomized?
  directions = [N, S, E, W].sort_by{rand}

  # iterate thru each element in the directions array
  directions.each do |direction|
    puts "direction:" + direction.to_s
    puts "opposite:" + OPPOSITE[direction].to_s
	# nx = next x coordinate as represented by its grid location
	# ny = next y coordinate as represented by its grid location
    nx, ny = cx + DX[direction], cy + DY[direction]
    
	puts "nx:" + nx.to_s
	puts "ny:" + nx.to_s
	
	# now we check that the next coordinate set is valid (on the maze) and hasn't yet been visited
    if ny.between?(0, grid.length-1) && nx.between?(0, grid[ny].length-1) && grid[ny][nx] == 0
      grid[cy][cx] |= direction
	  puts grid
	  puts "----------------------------"
      grid[ny][nx] |= OPPOSITE[direction]
	  puts grid
	  puts "-----------------------------"
      carve_passages_from(nx, ny, grid)
    end
  end
end

carve_passages_from(0, 0, grid)

# --------------------------------------------------------------------
# 4. A simple routine to emit the maze as ASCII
# --------------------------------------------------------------------

puts " " + "_" * (width * 2 - 1)
height.times do |y|
  print "|"
  width.times do |x|
    print((grid[y][x] & S != 0) ? " " : "_")
    if grid[y][x] & E != 0
      print(((grid[y][x] | grid[y][x+1]) & S != 0) ? " " : "_")
    else
      print "|"
    end
  end
  puts
end

# --------------------------------------------------------------------
# 5. Show the parameters used to build this maze, for repeatability
# --------------------------------------------------------------------

puts "#{$0} #{width} #{height} #{seed}"

puts grid