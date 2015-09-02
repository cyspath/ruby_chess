class ComputerPlayer

  attr_reader :color

  def initialize(color, game, board)
    @color = color
    @game = game
    @board = board
  end


  def select_and_move(arr)
    delay = 2 + rand(2)
    sleep delay
    #  if not being checked
    if arr.nil? || arr.empty?
      all_computer_pieces = get_all_computer_pieces

      print all_computer_pieces.map { |x| x.icon }
      while true

        piece = all_computer_pieces.sample
        puts "computer picked" + piece.icon

        end_pos = piece.moves.sample

        if @board.valid_move?(piece.current_position, end_pos)
          @board.move!(piece.current_position, end_pos)
          break
        else
          next
        end


      end

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
