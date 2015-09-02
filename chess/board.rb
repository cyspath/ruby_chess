require_relative 'emptysquare'
require_relative 'piece'
require 'colorize'

class Board
  attr_accessor :cursor_pos, :grid

  def initialize
    @grid = Array.new(8) {Array.new(8) {EmptySquare.new}}
    self.populate
    @cursor_pos = [0,0]
    @white_captured_pieces = []
    @black_captured_pieces = []
  end

  def render
    system ("clear")
    puts # spacer
    puts "    A  B  C  D  E  F  G  H".colorize(:color => :light_black)

    row_number = 8
    @grid.each_with_index do |row, row_idx|
      print (" " + row_number.to_s + " ").colorize(:color => :light_black)
      row.each_with_index do |square, square_idx|
        if [row_idx, square_idx] == @cursor_pos
          if square.color == :white
            print " #{square.icon} ".colorize(:color => :light_white, :background => :light_green)
          else
            print " #{square.icon} ".colorize(:color => :light_white, :background => :light_green)
          end
        elsif (square_idx + row_idx).even?
          if square.color == :white
            print " #{square.icon} ".colorize(:color => :light_white, :background => :black)
          else
            print " #{square.icon} ".colorize(:color => :light_white, :background => :black)
          end
        else
          if square.color == :white
            print " #{square.icon} ".colorize(:color => :light_white, :background => :red)
          else
            print " #{square.icon} ".colorize(:color => :light_white, :background => :red)
          end
        end

      end
      print (" " + row_number.to_s + " ").colorize(:color => :light_black)

      if row_number == 8
        print convert_captured_array_to_str(@black_captured_pieces)
      elsif row_number == 1
        print convert_captured_array_to_str(@white_captured_pieces)
      end

      row_number -= 1
      puts
    end
    puts "    A  B  C  D  E  F  G  H".colorize(:color => :light_black)
    puts # spacer
    puts # spacer
    puts # spacer
    puts # spacer

  end

  def convert_captured_array_to_str(arr)
    return arr.join("")
  end

  def move!(start_pos, end_pos)
    if valid_move?(start_pos, end_pos)
      #change pieces positions (alot of stuff going on here)
      #capture, move
      piece_to_move = current_piece(start_pos)
      target = current_piece(end_pos)

      add_to_captured_collection(target)

      @grid[end_pos[0]][end_pos[1]] = piece_to_move
      @grid[start_pos[0]][start_pos[1]] = EmptySquare.new
      piece_to_move.current_position = end_pos
    else
      # raise StandardError
    end
  end

  def add_to_captured_collection(target)
    if target.color == :white
      @black_captured_pieces.push(target.icon)
    elsif target.color == :black
      @white_captured_pieces.push(target.icon)
    end
  end

  def valid_move?(start_pos, end_pos)
    if possible_moves_has_end_pos?(start_pos, end_pos) &&
        no_friendly_piece(start_pos, end_pos) &&
        no_blocks_in_path(start_pos, end_pos) &&
        check_pawn_valid_move(start_pos, end_pos) #needs work
        # p "valid move! #{start_pos} - #{end_pos}"
      return true
    end
    # p "not valid move"
    false
  end

  def check_pawn_valid_move(start_pos,end_pos)
    piece_to_check = current_piece(start_pos)
    return true unless piece_to_check.is_a?(Pawn)
    # also return true if enemy piece is NOT diag from it
    if (start_pos[1] == end_pos[1] && current_piece(end_pos).empty?) ||
       (start_pos[1] != end_pos[1] && !current_piece(end_pos).empty? && current_piece(end_pos).color != piece_to_check.color)
      return true
    else
      false
    end
  end

  def no_friendly_piece(start_pos, end_pos)
    return true if @grid[end_pos[0]][end_pos[1]].empty?
    chosen_piece_color = current_piece(start_pos).color
    end_piece_color =  current_piece(end_pos).color
    return false if chosen_piece_color == end_piece_color
    true
  end

  def no_blocks_in_path(start_pos, end_pos)
    chosen_piece = current_piece(start_pos)
    if !chosen_piece.is_a?(SlidingPiece)
      return true
    else #we have a slidingpiece and we need to check for blocks
      direction_arr = chosen_piece.directional_moves_array
      current_direction_arr = []  # a direction arr containing endpos
      direction_arr.each do |arr|
        current_direction_arr = arr if arr.include?(end_pos)
      end
      current_direction_arr.each do |pos|
        piece = current_piece(pos)
        if pos != end_pos && !piece.empty?
          #{puts "something is blocking the path"}
          return false
        end
        if pos == end_pos
          #{puts "path clear"}
          return true
        end
      end
    end
  end

  def possible_moves_has_end_pos?(start_pos, end_pos)
    row_end, col_end = end_pos
    chosen_piece = current_piece(start_pos)
    target = current_piece(end_pos)
    # puts "chosen piece is #{chosen_piece.icon}, all possible moves: #{chosen_piece.moves}"
    return true if chosen_piece.moves.include?(end_pos) && target.color != chosen_piece.color
    false
  end

  def in_check?(color)
    king_in_check = false
    kings_pos = find_king(color)
    @grid.each_with_index do |row, row_idx|
      row.each_with_index do |square, square_idx|
        if !square.empty? && square.color != color
          king_in_check = true if valid_move?([row_idx, square_idx], kings_pos)
        end
      end
    end
    king_in_check
  end

  def find_king(color)
    kings_pos = []
    @grid.each_with_index do |row, row_idx|
      row.each_with_index do |square, square_idx|
        kings_pos = [row_idx, square_idx] if square.is_king? && square.color == color
      end
    end
    kings_pos
  end

  def king_exist?(color)
    exist = false
    @grid.each_with_index do |row, row_idx|
      row.each_with_index do |square, square_idx|
        exist = true if square.is_king? && square.color == color
      end
    end
    exist
  end

  def current_piece(pos)
    row, col = pos
    chosen_piece = @grid[row][col]
  end

  def dupe
    new_board = Board.new
    copy_grid = new_board.grid
    @grid.each_with_index do |row, row_idx|
      row.each_with_index do |square, col_idx|
        if !square.empty?
          copy_grid[row_idx][col_idx] = square.class.new([row_idx, col_idx], square.color, Board.new)
        else
          copy_grid[row_idx][col_idx] = square.class.new
        end
      end
    end
    new_board
  end

  def populate
    #change @grid to contain instances of all pieces
    @grid.each_with_index do |row, row_idx|
      row.each_with_index do |square, square_idx|
        start_position = [row_idx, square_idx]
        if row_idx == 0
          # populate with black pieces, non-pawns
          case square_idx
          when 0, 7
            @grid[row_idx][square_idx] = Rook.new(start_position, :black, self)
          when 1, 6
            @grid[row_idx][square_idx] = Knight.new(start_position, :black, self)
          when 2, 5
            @grid[row_idx][square_idx] = Bishop.new(start_position, :black, self)
          when 3
            @grid[row_idx][square_idx] = King.new(start_position, :black, self)
          when 4
            @grid[row_idx][square_idx] = Queen.new(start_position, :black, self)
          end
        elsif row_idx == 1
          # populate with black pieces, pawns
          @grid[row_idx][square_idx] = Pawn.new(start_position, :black, self)
        elsif row_idx == 6
          # populate with white pieces, pawns
          @grid[row_idx][square_idx] = Pawn.new(start_position, :white, self)
        elsif row_idx == 7
          # populate with white pieces, non-pawns
          case square_idx
          when 0, 7
            @grid[row_idx][square_idx] = Rook.new(start_position, :white, self)
          when 1, 6
            @grid[row_idx][square_idx] = Knight.new(start_position, :white, self)
          when 2, 5
            @grid[row_idx][square_idx] = Bishop.new(start_position, :white, self)
          when 3
            @grid[row_idx][square_idx] = King.new(start_position, :white, self)
          when 4
            @grid[row_idx][square_idx] = Queen.new(start_position, :white, self)
          end
        end
      end
    end


  end

  def move_cursor(increment)
    r,c = increment
    @cursor_pos = [(@cursor_pos[0] + r), (@cursor_pos[1] + c)]
  end

end
