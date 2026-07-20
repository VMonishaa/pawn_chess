# Pawn-Only Chess

A chess game with only pawns. You play one color, the computer plays
the other. Built with Ruby on Rails 8 (API only, no frontend yet) and
PostgreSQL.

## The rules

- The board is 8x8. Black's 8 pawns start on row 0 (top) and move down.
  White's 8 pawns start on row 7 (bottom) and move up. White always moves
  first.
- A pawn can move one step straight forward, only if that square is empty.
- A pawn can capture by moving one step diagonally forward, only if an
  opponent pawn is standing there.
- No double-step, no en passant, no promotion.

You win if one of your pawns reaches the other end of the board, or if you
capture all of the opponent's pawns. If the player who has to move has no
legal move at all, the game is a draw.

## How to run it

You need Ruby 3.2+ and PostgreSQL running locally.

bundle install
rails db:create db:migrate
rails server


That's it. The API is now on `localhost:3000`.

## The API

All squares use simple numbers: row 0-7 and col 0-7. Row 0 is the top.

**Start a game** (pick your color, default is white):

curl -X POST localhost:3000/api/v1/games \
  -H "Content-Type: application/json" -d '{"color":"white"}'


If you pick black, the computer (white) makes its first move right away,
so the board you get back is already waiting for you.

**Make a move** (the computer replies in the same response):

curl -X POST localhost:3000/api/v1/games/1/moves \
  -H "Content-Type: application/json" \
  -d '{"from":{"row":7,"col":3},"to":{"row":6,"col":3}}'

If your move is illegal you get a clear error, like
"Destination square is occupied".

**Everything else:**

curl localhost:3000/api/v1/games/1                  # get the game (this is how you resume)
curl -X PATCH localhost:3000/api/v1/games/1/pause   # pause (moves get rejected)
curl -X PATCH localhost:3000/api/v1/games/1/resume  # continue playing
curl -X POST  localhost:3000/api/v1/games/1/restart # same game id, fresh board

Every response includes the full game state: whose turn it is, both
players' pawn counts, the board as an 8x8 array, and also a `board_display`
that prints nicely in the terminal:

. B B B B B B B
. . . . . . . .
B . . . . . . .
. . . . . . . .
. . . . . . . .
. . . W . . . .
. . . . . . . .
W W W . W W W W


## How the computer picks its move

It looks at every move its pawns can make, and for each one it checks:
"if I go here, can an enemy pawn capture me on my next square?" Then it
picks the first option from this list that exists:

1. A move that wins the game right now (reaches the last row)
2. A capture where it cannot be captured back
3. Any capture
4. A safe forward move (preferring the pawn closest to winning)
5. Any legal move, if nothing safe is left

Nothing is actually moved while it is thinking — it only checks squares.
The real move happens once, through the same code path a user move goes
through.

## How it's built

- **Models**: Game, Board, Pawn, Player (one user, one system),
  and GamePlayer, which stores each player's per-game info: their color
  and pawn counters.
- **Services**: the logic lives in small service classes, not in the models
  or controllers:
  - GameCreator - sets up the game, board, players and 16 pawns
  - MoveValidator - the referee: says if a move is legal and why not
  - MoveExecutor - actually moves the pawn, handles captures, checks
    win/draw, flips the turn - all inside one DB transaction
  - SystemTurn - the computer's brain (the priority list above)
  - GameRestarter - resets a game without changing its id
- **Controllers** just read params, call the services and return JSON.

Some decisions and the reason behind them:

- **Service objects instead of model callbacks** - all setup logic sits in
  one readable file, and restart can reuse it. Callbacks would scatter the
  flow across models and only run on create.
- **Captured pawns are flagged, not deleted** - we keep the row and mark it
  captured. That keeps history and counters honest. The cost is that every
  board lookup filters on "available", which the scopes handle.
- **user_color is stored on the game** - it can never change after
  creation, so duplicating it there is safe, and it saves a join every time
  we ask "whose turn is it?".
- **Validator and executor are separate** - "is this legal?" gets asked a
  lot (draw checks, the computer comparing options) without changing
  anything. Only the executor writes to the DB.
- Every move is saved inside a transaction, so a half-finished move can
  never end up in the database. Resume is just loading the game by id.

## Not in this round

Frontend (the API returns everything a UI needs), authentication, and move
history. The schema would support multiple users later - only the players
table would need real identities.
