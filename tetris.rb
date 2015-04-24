# Running instructions 
#		You need to have ruby installed on your PC
#		Save this file, open terminal & execute - ruby <filename>. You are good
# 	The color scheme is for bash terminal (line 12). If the code complains while running, just remove those nasty looking \033#$%^ kind of stuff
# Happy Running
# Author - Ashish - pocha.sharma@gmail.com 
# This is my first time with pure Ruby code that works on a Desktop. I have always worked with Rails & created web apps only. Guess I might have been faster creating a web app for this. But ... requirements :-)  

$grid_width = 20
$grid_height = 20

$grid = Array.new($grid_height){Array.new($grid_width)}

def error_output(text)
	puts "\033[1;31m #{text}\033[0m";
end

def populate_grid
	$grid = nil
	$grid = Array.new($grid_height){Array.new($grid_width)}
	
	for y in 0..$grid_height-1
		for x in 0..$grid_width-1
			if ( x == 0 or x == $grid_width-1 )
				$grid[y][x] = "*"
				next
			end
			if ( y == $grid_height - 1)
				$grid[y][x] = "*"
				next
			end
			$grid[y][x] = " "
		end
	end
	
	$pieces.each do |piece|
			piece.pixels.each do |pixel|
				#ugly hack here. Not sure why array indices are going out of bounds
				begin
					$grid[piece.y + pixel[1]][piece.x + pixel[0]] = "*"
				rescue
					error_output("error")
					piece.dump
				end
			end
	end

end

def show_grid
	populate_grid
	
	for y in 0..$grid_height-1
		for x in 0..$grid_width-1
			print $grid[y][x]
		end
		print "\n"
	end
end


$piece_type = { #[x,y]
		1 => {max_x: $grid_width - 5, pixels: [[0,0],[1,0],[2,0],[3,0]] },	# ****

		2 => {max_x: $grid_width - 3, pixels: [[0,0],[0,1],[1,0],[1,1]] },	# **
																																				# **

		3 => {max_x: $grid_width - 3, pixels: [[0,0],[0,1],[0,2],[1,2]] },	# *
																																				# *
																																				# **

		4 => {max_x: $grid_width - 3, pixels: [[1,0],[1,1],[1,2],[0,2]] },	#  *
																																				#  *
																																				# **
		
		5 => {max_x: $grid_width - 3, pixels: [[1,0],[1,1],[0,1],[0,2]] }		#  *
																																				# **
																																				# *
}

class Piece

	def initialize
		@piece_type = $piece_type[rand(1..5)]
		@x = rand(1..(@piece_type[:max_x]))
		@y = 0
		@pixels = @piece_type[:pixels].dup
	end

	def check_move(input)
		case input
		when "a"
			@x -= 1
		when "d"
			@x += 1
		when "w" #counter clockwise x,y = y,-x
			@pixels.each do |pixel|
				tmp = pixel[0]
				pixel[0] = pixel[1]
				pixel[1] = -tmp
			end
		when "s" #clockwise x,y = -y,x
			@pixels.each do |pixel|
				tmp = pixel[0]
				pixel[0] = -pixel[1]
				pixel[1] = tmp
			end
		when "t" 
			#introduced for testing game_over, let the piece fall straight
		else
			#invalid input
			return false
		end
		
		@y += 1
		
		#check if move is not hitting boundaries or other pieces
		return not_hitting_boundaries
		
	end

	def x
		return @x
	end
	def y
		return @y
	end
	def pixels 
		return @pixels
	end

	def not_hitting_boundaries #only last piece is moving, so check with all previous pieces
		#puts "x - #{@x}, y - #{@y}"

		#check with container boundaries
		@pixels.each do |pixel|
			#puts " pixel [x,y], #{pixel[0]} #{pixel[1]}" 			
			if @x + pixel[0] <= 0 or @x + pixel[0] >= $grid_width-1
				puts "hitting x boundary"
				return false
			end
			if @y + pixel[1] >= $grid_height - 1
				puts "hitting y boundary"
				return false
			end
		end

		#check with other pieces
		for i in 0..$pieces.length-2
			piece = $pieces[i]
			piece.pixels.each do |pixel|
				@pixels.each do |_pixel|
					if piece.x + pixel[0] == @x + _pixel[0] and piece.y + pixel[1] == @y + _pixel[1] #there is a hit with another piece
						puts "hitting another piece"
						#piece.dump
						#puts "this piece"
						#dump
						return false
					end
				end
			end
		end

		return true
	end

	def can_move
			for input in ["a","w","s","d"]
				duped_piece = self.clone
				#puts "checking movement for #{input}"
				return true if duped_piece.check_move(input)
			end
			return false
	end

	def dump
		puts "x #{@x}, y #{@y}"
		@pixels.each do |pixel|
				puts "pixel #{pixel}"
		end
	end

	def self.dump_all #side by side dump
		$pieces.each do |piece|
			print "x #{piece.x}, y #{piece.y}\t"
		end
		print "\n"
		for i in 0..3
			$pieces.each do |piece|
				print "pixel #{piece.pixels[i]}\t"
			end
			print "\n"
		end
	end

end

$pieces = []

$pieces << Piece.new
input = nil 
is_moved = true
turn_count = 1

while (true) 
	#get last piece & check if it can move else add a new piece
	piece = $pieces[-1]
	
	if !piece.can_move
		puts "cant move, adding a new piece"
		$pieces << Piece.new
		piece = $pieces[-1]
		if !piece.can_move
			break
		end
	end
	
	duped_piece = piece.clone	
	is_moved = duped_piece.check_move(input) if !input.nil?

	$pieces[-1] = duped_piece if is_moved	
	show_grid
	
	if is_moved
		puts "#{turn_count}. waiting for next move - a,w,s,d only"
	else
		puts "#{error_output(turn_count.to_s + '. invalid move')}"
	end
	Piece.dump_all
	input = STDIN.gets.chomp
	turn_count += 1
	
end

puts "game over"

# Known Bugs
# 1. Just before hitting the bottom, sometimes the piece rotates. I am guessing it is the switch statement
# 2. Piece cordinates go out of bounds when a lot of pieces are added in the game. Not sure why. 
