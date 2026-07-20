# app/controllers/api/v1/games_controller.rb
module Api
  module V1
    class GamesController < ApplicationController
      before_action :set_game, only: %i[show pause resume restart]

      def create
        color = params.fetch(:color, "white").to_s.downcase
        unless Game::COLORS.include?(color)
          return render json: { error: "color must be white or black" }, status: :unprocessable_entity
        end

        game = GameCreator.new(user_color: color).call
        SystemTurn.call(game) if color == "black" # if user picked black then system starts
        render json: GameSerializer.call(game.reload), status: :created
      end

      def show
        render json: GameSerializer.call(@game)
      end

      def pause
        unless @game.in_progress?
          return render json: { error: "Only an in-progress game can be paused" }, status: :unprocessable_entity
        end
        @game.paused!
        render json: GameSerializer.call(@game)
      end

      def resume
        unless @game.paused?
          return render json: { error: "Only a paused game can be resumed" }, status: :unprocessable_entity
        end
        @game.in_progress!
        render json: GameSerializer.call(@game)
      end

      def restart
        GameRestarter.call(@game)
        SystemTurn.call(@game) if @game.user_color == "black" # same -> if user picked black then system starts
        render json: GameSerializer.call(@game.reload)
      end

      private

      def set_game
        @game = Game.find(params[:id])
      end
    end
  end
end
