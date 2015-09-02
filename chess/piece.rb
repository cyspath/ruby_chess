require_relative 'board'

class Piece
  attr_accessor :icon, :color, :current_position

  def initialize(start_position = nil, color = :black, reference_board)
    @icon = "Ҏ"
    @current_position = start_position
    @color = color
    @reference_board = reference_board
  end

  def is_king?
    false
  end

  def moves
    #should return an array of places a piece can move to
    r, c = @current_position

    diagonals = []
    r_up, r_down, l_down, l_up = [], [], [], []
    (1..7).each do |num|
      l_up << [r - num, c - num]
      r_up << [r - num, c + num]
      r_down << [r + num, c + num]
      l_down << [r + num, c - num]
    end
    diagonals << r_up << r_down << l_down << l_up
    diagonals.each do |direction_array|
      direction_array.select! do |pairs|
        (0..7).include?(pairs[0]) && (0..7).include?(pairs[1])
      end
    end

    vertical_horizontal = []
    up, down, left, right = [], [], [], []
    # (1..7).each do |num|
    #   vertical_horizontal << [r, c - num] << [r, c + num] << [r + num, c] << [r - num, c]
    # end
    (1..7).each do |num|
      up << [r - num, c]
      down << [r + num, c]
      left << [r, c - num]
      right << [r, c + num]
    end
    vertical_horizontal << up << right << down << left
    vertical_horizontal.each do |direction_array|
      direction_array.select! do |pairs|
        (0..7).include?(pairs[0]) && (0..7).include?(pairs[1])
      end
    end

    l_step = [  [r - 2, c + 1],
                [r - 1, c + 2],
                [r + 1, c + 2],
                [r + 2, c + 1],
                [r + 2, c - 1],
                [r + 1, c - 2],
                [r - 1, c - 2],
                [r - 2, c - 1]  ]
    l_step.select! {|pairs| (0..7).include?(pairs[0]) && (0..7).include?(pairs[1]) }

    [diagonals, vertical_horizontal, l_step]
    # diagonals = [[diag-up-r], [], [], []]
    # diag-up-r = [[x,y], [x1,y1]]
  end

  def empty?
    false
  end

  def filter_occupied_target_pos_from_all_possible_moves(all_moves)
    # make sure valid_moves returns only pos array with square that are not occupied
    arr = []
    all_moves.each do |pos|
      if @reference_board.grid[pos[0]][pos[1]].color != @color
        arr.push(pos)
      end
    end
    return arr
  end

  def valid_moves
    # iterate through grid
    # for each piece, deep dup board
    positions_to_remove = []
    board_dup =  @reference_board.dupe
    all_possible_moves = moves
    all_possible_moves.each do |pos|
      board_dup.move!(@current_position, pos)
      # in check?
      positions_to_remove << pos if board_dup.in_check?(@color)
      board_dup =  @reference_board.dupe
    end
    all_possible_moves.reject! { |pos| positions_to_remove.include?(pos) }
    # puts "#{@icon}: #{all_possible_moves} to get out of check"
    filter_occupied_target_pos_from_all_possible_moves(all_possible_moves)
  end

  def valid_piece
    pieces = false #value in this does not matter now or later
    board_dup =  @reference_board.dupe
    all_possible_moves = moves
    all_possible_moves.each do |pos|
      if board_dup.valid_move?(@current_position, pos)
        board_dup.move!(@current_position, pos)
      end
      if board_dup.in_check?(@color) == false
        pieces = true
        break
      end
      board_dup =  @reference_board.dupe
    end
    pieces #value in this does not matter now or later
  end

end

##############################################

class SlidingPiece < Piece

  def moves
    possible_moves = super.take(2)
  end
end

class SteppingPiece < Piece

  def moves
    super
  end
end

##################### KING #########################

class King < SteppingPiece
  attr_accessor :all_possible_moves
  def initialize(start_position = nil, color = :black, reference_board)
    super(start_position, color, reference_board)
    assign_icon
    @all_possible_moves = moves
  end

  def assign_icon
    if @color == :black
      @icon = "♛"
    elsif @color == :white
      @icon = "♕"
    end
  end

  def is_king?
    true
  end

  def moves
    r, c = @current_position
    possible_moves = super.take(2).flatten(2)
    possible_moves.select! do |position_pairs|
      position_pairs[0] <= r + 1 && position_pairs[0] >= r - 1 && position_pairs[1] <= c + 1 && position_pairs[1] >= c - 1
    end
    possible_moves
  end


end

##################### QUEEN #########################


class Queen < SlidingPiece
  attr_accessor :all_possible_moves, :directional_moves_array

  def initialize(start_position = nil, color = :black, reference_board)
    super(start_position, color, reference_board)
    assign_icon
    @directional_moves_array = [] # will be built in #moves
    @all_possible_moves = moves
  end

  def assign_icon
    if @color == :black
      @icon = "♚"
    elsif @color == :white
      @icon = "♔"
    end
  end

  def moves
    all_possible_moves = super.flatten(1)
    @directional_moves_array = directional_array(all_possible_moves)
    #check if something is blocking the path
    all_possible_moves.flatten(1)
  end

  def directional_array(moves_arr)
    direction_arr = moves_arr.select { |sub_arr| !sub_arr.empty? }
    direction_arr # returns [[r_up], [r_down]... ]
  end

end

##################### BISHOP #########################

class Bishop < SlidingPiece
  attr_accessor :all_possible_moves, :directional_moves_array

  def initialize(start_position = nil, color = :black, reference_board)
    super(start_position, color, reference_board)
    assign_icon
    @directional_moves_array = [] # will be built in #moves
    @all_possible_moves = moves
  end

  def assign_icon
    if @color == :black
      @icon = "♝"
    elsif @color == :white
      @icon = "♗"
    end
  end

  def moves
    all_possible_moves = super[0]
    @directional_moves_array = directional_array(all_possible_moves)
    all_possible_moves.flatten(1)
  end

  def directional_array(moves_arr)
    direction_arr = moves_arr.select { |sub_arr| !sub_arr.empty? }
    direction_arr # returns [[r_up], [r_down]... ]
  end

end

##################### KNIGHT #########################

class Knight < SteppingPiece
  attr_accessor :all_possible_moves
  def initialize(start_position = nil, color = :black, reference_board)
    super(start_position, color, reference_board)
    assign_icon
    @all_possible_moves = moves
  end

  def assign_icon
    if @color == :black
      @icon = "♞"
    elsif @color == :white
      @icon = "♘"
    end
  end

  def moves
    all_possible_moves = super.last
  end


end

##################### ROOK #########################

class Rook < SlidingPiece
  attr_accessor :all_possible_moves, :directional_moves_array
  def initialize(start_position = nil, color = :black, reference_board)
    super(start_position, color, reference_board)
    assign_icon
    @directional_moves_array = [] # will be built in #moves
    @all_possible_moves = moves
  end

  def assign_icon
    if @color == :black
      @icon = "♜"
    elsif @color == :white
      @icon = "♖"
    end
  end

  def moves
    all_possible_moves = super[1]
    @directional_moves_array = directional_array(all_possible_moves)
    all_possible_moves.flatten(1)
  end

  def directional_array(moves_arr)
    direction_arr = moves_arr.select { |sub_arr| !sub_arr.empty? }
    direction_arr # returns [[r_up], [r_down]... ]
  end

end

##################### PAWN #########################

class Pawn < Piece
  attr_accessor :all_possible_moves
  attr_accessor :start_position, :current_position # for testing pawn's path

  def initialize(start_position = nil, color = :black, reference_board)
    super(start_position, color, reference_board)
    assign_icon
    @start_position = start_position
    @all_possible_moves = moves
  end
  #
  # def make_move(end_pos)
  #   @current_position = end_pos
  # end

  def assign_icon
    if @color == :black
      @icon = "♟"
    elsif @color == :white
      @icon = "♙"
    end
  end

  def moves
    #depends on color
    #depends on current position since it can move 2 spaces atfirst
    #only moves forward, will not return to start_position
    if @color == :white
      if @current_position == @start_position
         all_possible_moves = super[1][0][0..1]
         all_possible_moves << super[0][0][0] unless super[0][0][0].nil?
         all_possible_moves << super[0][3][0] unless super[0][3][0].nil?
      else
         all_possible_moves = super[1][0].take(1)
         all_possible_moves << super[0][0][0] unless super[0][0][0].nil?
         all_possible_moves << super[0][3][0] unless super[0][3][0].nil?
       end
    elsif @color == :black
      if @current_position == @start_position
         all_possible_moves = super[1][2][0..1]
         all_possible_moves << super[0][1][0] unless super[0][1][0].nil?
         all_possible_moves << super[0][2][0] unless super[0][2][0].nil?
      else
         all_possible_moves = super[1][2].take(1)
         all_possible_moves << super[0][1][0] unless super[0][1][0].nil?
         all_possible_moves << super[0][2][0] unless super[0][2][0].nil?
       end
    end

      all_possible_moves
  end

end


# ♜	♞	♝	♛	♚	♝	♞	♜
# ♟	♟	♟	♟	♟	♟	♟	♟
# ♙	♙	♙	♙	♙	♙	♙	♙
# ♖	♘	♗	♕	♔	♗	♘	♖
