# Chess

Screen recording of a chess game played in the terminal vs a computer player

<img src='https://raw.github.com/cyspath/Chess/master/chess.gif' align='center' padding='10px'>

### Game Modes
* Human vs. Human
* Human vs. Computer
* Computer vs Computer

I have implemented a simple computer AI that will always capture your pieces when possible, before attempting to make a valid move.

### Controls/Cursor

For human player this game can be played using "WASD" and "Enter" in the terminal (io/console).

To play, run chess.rb and enter `Chess.new.run`

### Additional Details
* Classes/Models: `Chess Game`, `Board`, `Empty Square`, `Piece`, `Human Player`, `Computer Player`
* Individual chess pieces inherits from either `Sliding Piece` or `Stepping Piece`, which inherits from `Piece`
* When a player's king is checked, that player is only allowed to move the pieces that will uncheck his or her king
