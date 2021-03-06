require 'json'

class Board
  attr_reader :matrix
  def initialize(matrix=nil)
    if matrix
      @matrix = matrix
    else
      @matrix = Array.new(9) { Array.new(9) { {b: false, display: "*"} } }
    end
    @lost, @win = false, false
  end

  def display_board
    @matrix.length.times do | x |
      @matrix[0].length.times do | y |
        print " #{@matrix[x][y][:display]} "
      end
      print "\n"
    end
    nil
  end

  def set_bombs
    bombs_coords.each do |coord|
      @matrix[coord[0]][coord[1]][:b] = true
    end
  end

  def bombs_coords
    bomb_array = []
    until bomb_array.length == 10
      bomb_coords = [rand(9), rand(9)]
      unless bomb_array.include?(bomb_coords)
        bomb_array << bomb_coords
      end
    end
    bomb_array
  end

  def set_square(coords, value)
    @matrix[coords[0]][coords[1]][:display] = value
  end

  def display_square(coords)
    @matrix[coords[0]][coords[1]]
  end

  def find_neighbors(coords)
    vectors = [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]
    neighbors = []
    vectors.each do |vector|
      unless ((coords[0]+vector[0]) < 0 || (coords[1]+vector[1]) < 0) || ((coords[0]+vector[0]) > 8 || (coords[1]+vector[1]) > 8)
        checking_x = coords[0]+vector[0]
        checking_y = coords[1]+vector[1]
        neighbors << [checking_x,checking_y]
      end
    end
    neighbors
  end

  def set_flag(coords)
    @matrix[coords[0]][coords[1]][:display] = "F"
  end

  def expose_square(coords)
    if is_bomb?(coords)
      set_square(coords, "B")
      lose
    elsif is_flag?(coords)
      puts "That is a Flag, pick another square!"
    elsif exposed?(coords)
      puts "Exposed, pick another square!"
    else
      update_square(coords)
    end
  end

  def exposed?(coords)
    current_state = display_square(coords)[:display]
    current_state.is_a?(Fixnum) ? true : false
  end

  def is_bomb?(coords)
    @matrix[coords[0]][coords[1]][:b]
  end

  def is_flag?(coords)
    @matrix[coords[0]][coords[1]][:display] == "F" ? true : false
  end

  def update_square(coord)
    neighbors = find_neighbors(coord)
    bomb_num = neighbor_bomb_count(neighbors)
    set_square(coord, bomb_num)
    check_neighbors(neighbors) if bomb_num == 0
  end

  def check_neighbors(neighbors)
    neighbors.each do | neighbor |
      next if display_square(neighbor)[:b]
      next if display_square(neighbor)[:display].is_a?(Fixnum)
      update_square(neighbor)
    end
  end

  def neighbor_bomb_count(neighbors)
    bomb_num = 0
    neighbors.each do |neighbor|
      bomb_num += 1 if @matrix[neighbor[0]][neighbor[1]][:b]
    end
    bomb_num
  end

  def lose
    @lost = true
  end

  def win
    # find '*' if no '*' then all bombs are flagged, win!
    stars = []
    @matrix.length.times do | x |
      @matrix[0].length.times do | y |
        stars << '*' if @matrix[x][y][:display] == '*'
      end
    end
    @win = true if b.empty?
  end

  def game_over?
    true if @win || @lost
  end

end

class Minesweeper
  def initialize
    @board
  end

  def load_game
    puts "New Game or Load Game? (n/l)"
    start = gets.chomp.downcase

    if start=='l'
      load_file
    else
      @board = Board.new
      @board.set_bombs
    end
    play
  end

  def play
    until @board.game_over?
      @board.display_board
      prompt_user
    end
    @board.display_board
    puts "Game over!"
  end

  def prompt_user
    puts "Reveal a square or flag a square? (r/f/s)\n"
    type_of_action = gets.chomp.downcase

    save if type_of_action == 's'

    puts "Pick a Coordinate" # user enters two numbers, one space, no comma
    coord = gets.chomp.split(' ').map(&:to_i)
    if type_of_action == 'f'
      @board.set_flag(coord)
    elsif type_of_action == 'r'
      @board.expose_square(coord)
    end
  end

  def load_file
    json = File.read('game.JSON')
    board_array = JSON.parse(json, symbolize_names: true)[:board]
    @board = Board.new(board_array)
  end

  def save
    File.open("game.json", "w") do |f|
      test = {"board" => @board.matrix }
      f.puts test.to_json
    end
    puts "Goodbye!"
    exit
  end
end

m = Minesweeper.new
m.load_game









