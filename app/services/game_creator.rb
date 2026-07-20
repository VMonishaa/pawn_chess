class GameCreator

    def initialize(user_color:)
        @user_color = user_color
    end
    
    def call
        ActiveRecord::Base.transaction do
            create_game
            create_board
            find_or_create_players
            create_game_players
            create_pawns
        end
        @game
    end

    private
    def create_game
        @game = Game.create!(user_color:  @user_color)
    end

    def create_board
        @board = Board.create!(game: @game)
    end

    def find_or_create_players
        @user_player = UserPlayer.first_or_create! #since no authentication its single user game, later can be extended by adding user specific columns
        @system_player = SystemPlayer.first_or_create!
    end
    
    def create_game_players
        @user_gp = GamePlayer.create!(game: @game, player:  @user_player, color: @user_color)
        @system_gp = GamePlayer.create!(game: @game, player: @system_player, color: get_system_color)
    end

    def create_pawns
        {"black": 0, "white": 7}.each do |color, row|
            game_player = (color == @user_color) ? @user_gp : @system_gp
            8.times do |col|
                Pawn.create!(board: @board, game_player: game_player, color: color, row: row, col: col)
            end
        end
    end

    def get_system_color
        (@user_color == "white") ? "black" : "white"
    end

end
