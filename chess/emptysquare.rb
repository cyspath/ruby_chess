class EmptySquare

  attr_reader :icon, :color

  def initialize
    @icon = " "
    @color = :blue
  end

  def empty?
    true
  end

  def is_king?
    false
  end

  def valid_moves
  end

end
