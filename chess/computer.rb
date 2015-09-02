
class ComputerPlayer

  attr_reader :color

  def initialize(color, game, board)
    @color = color
    @game = game
    @board = board
  end


  def select_and_move(arr)
    # delay = 1 + rand(2)
    # sleep delay
    #  if not being checked
    if arr.nil? || arr.empty?
      all_computer_pieces = get_all_computer_pieces

      pieces = all_computer_pieces
      end_pos = nil

      pieces.each do |piece|
        @current_piece = piece
        piece.moves.each do |pos|
          target_piece = @board.current_piece(pos)
          if target_piece.color != @color && !target_piece.empty? && @board.valid_move?(piece.current_position, pos)
            end_pos = pos #pos of enemy piece in range
            @selected_piece = @current_piece
          end
        end
      end

      while end_pos.nil?
        @selected_piece = pieces.sample
        rand_pos = @selected_piece.moves.sample
        end_pos = rand_pos if @board.valid_move?(@selected_piece.current_position, rand_pos)
      end

      p end_pos
      p @selected_piece.icon
      p @selected_piece.current_position


      @board.move!(@selected_piece.current_position, end_pos)
      end_pos = nil;
    end

  end


  def get_all_computer_pieces
    arr = []
    @board.grid.each do |row|
      row.each do |col|
        arr.push(col)
      end
    end
    return arr.select {|x| x.color == @color }
  end

end
