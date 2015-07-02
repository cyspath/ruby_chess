require 'io/console'
require_relative 'player'
require_relative 'board'
# $stdin.getch
class Chess

  def initialize
    @board = Board.new
    @players = [Player.new(:white), Player.new(:black)]
    @force_quit = false
  end

  def run
    until game_over? || @force_quit
      render_board
      arr = in_check
      select_and_move(arr)
      render_board
      switch_player
      break if one_king_dies?
    end
    render_board
    game_over_message
  end

  def one_king_dies?
    !(@board.king_exist?(@players.first.color))
  end

  def in_check
    if @board.in_check?(@players.first.color)
      system("clear")
      puts "King(#{@players.first.color}) is in check!"
      puts "Please wait until board renders..."

      array_of_piece_positions = []
      @board.grid.each_with_index do |row, row_idx|
        row.each_with_index do |square, square_idx|

          if !square.empty? && square.color == @players.first.color
            array_of_piece_positions << [row_idx, square_idx] if square.valid_piece
          end

        end
      end
      render_board
    end
    array_of_piece_positions
  end

  def game_over?
    false
  end

  def render_board
    @board.render
  end

  def select_and_move(arr) #important method - contains alot
    start_pos = select_piece(arr)
    # add later: render board, with spaces
    # highlighted of where they could move
    end_pos = move_piece_to
    @board.move!(start_pos, end_pos)
  end

  def select_piece(arr)
    while true
      pos_of_piece = cursor_movement

      if arr.nil?
        break if !@board.current_piece(pos_of_piece).empty? && @board.current_piece(pos_of_piece).color == @players.first.color
      end

      if !arr.nil?
        break if !@board.current_piece(pos_of_piece).empty? && @board.current_piece(pos_of_piece).color == @players.first.color && arr.include?(pos_of_piece)
      end

      puts "Please choose one of your pieces." if arr.nil? || arr.empty?
      puts "You are in check, you can only move pieces that can help uncheck you!" if arr.nil? == false
    end
    pos_of_piece
  end

  def move_piece_to
    pos_of_move = cursor_movement
  end

  def switch_player
    @players.reverse!
  end

  def game_over_message
    puts "Good game, #{@players.last.color} king is victorious!"
  end

  def get_cursor_input
    raise "Not yet written"
  end

  def cursor_movement
    while true
      key_press = STDIN.getch
      # check if it was \r, if it is  we do things(later)
      increment = key_press_coordinate(key_press)
      @board.move_cursor(increment)
      @board.render
      @force_quit = true if key_press == "\u0003"
      break if key_press == "\u0003"
      # return the cursor position if \r
      return @board.cursor_pos if key_press == "\r"
    end
  end

  def key_press_coordinate(string)
    case string
    when "w"
      return CURSOR_MOVEMENT[0]
    when "d"
      return CURSOR_MOVEMENT[1]
    when "s"
      return CURSOR_MOVEMENT[2]
    when "a"
      return CURSOR_MOVEMENT[3]
    when "\r"
      return CURSOR_MOVEMENT[4]
    end
  end


CURSOR_MOVEMENT = [[-1,0], [0,1], [1, 0], [0,-1], [0,0]]
end
