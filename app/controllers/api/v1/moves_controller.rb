module Api
  module V1
    class MovesController < ApplicationController
      # /api/v1/games/:game_id/moves
      # body - { "from": {"row":7,"col":3}, "to": {"row":6,"col":3} }
      def create
        game = Game.find(params[:game_id])

        user_move = MoveExecutor.call(
          game: game, color: game.user_color,
          from_row: params.dig(:from, :row).to_i,
          from_col: params.dig(:from, :col).to_i,
          to_row: params.dig(:to, :row).to_i,
          to_col: params.dig(:to, :col).to_i
        )
        unless user_move[:success]
          return render json: { error: user_move[:error] }, status: :unprocessable_entity
        end

        system_move = SystemTurn.call(game.reload)

        render json: { user_move: user_move, system_move: system_move, game: GameSerializer.call(game.reload) }
      end
    end
  end
end
