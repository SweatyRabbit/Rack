# frozen_string_literal: true

module Lib
  module Entities
    class Game
      include Lib::Modules::WebHelper

      WRONG_NUMBER = 'X'

      def self.call(env)
        new(env).responce
      end

      def initialize(request)
        @request = request
        @game = @request.session[:game]
        @guess_number = @request.session[:guess_number]
        @guess_result = @request.session[:guess_result]
        @hints = @request.session[:hint_code]
        @errors = []
      end

      def responce
        case @request.path
        when Lib::Entities::Router::COMMANDS[:guess] then guess_number
        when Lib::Entities::Router::COMMANDS[:hint] then hint
        when Lib::Entities::Router::COMMANDS[:lose] then lose
        when Lib::Entities::Router::COMMANDS[:win] then win
        else respond(:game)
        end
      rescue CodebreakerGem::Error::OnlyNumbers, CodebreakerGem::Error::InputRange,
             CodebreakerGem::Error::MaxStringLength => e
        assign_errors(e)
      end

      private

      def guess_number
        return respond('game') unless @request.params['number']

        @guess_number = @request.params['number']
        @request.session[:guess_number] = @guess_number
        @guess_result = @game.use_attempt(@guess_number).dup
        @request.session[:guess_result] = @guess_result
        return win if @game.win?

        return lose if @game.lose?

        no_match_result
      end

      def win
        return respond(:game) if game_exist? && !@game.win?

        @game.save_current_statistic
        @request.session.clear
        respond(:win)
      end

      def lose
        return respond(:game) if game_exist? && !@game.lose?

        @request.session.clear
        respond(:lose)
      end

      def no_match_result
        (CodebreakerGem::Entities::Guess::MAX_INPUT - @guess_result.size).times { @guess_result << WRONG_NUMBER }
        @request.session[:result] = @guess_result
        respond('game')
      end

      def hint
        @hints = @request.session[:hint_code] || []
        if @game.user_hints.positive?
          @hints << @game.use_hint
          @request.session[:hint_code] = @hints
        end
        respond(:game)
      end

      def game_exist?
        @request.session[:game]
      end

      def assign_errors(error)
        @errors << error.message
        respond(:game)
      end
    end
  end
end
