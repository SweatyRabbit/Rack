# frozen_string_literal: true

module Lib
  module Entities
    class Game
      include Lib::Modules::WebHelper

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
        when Router::COMMANDS[:guess] then guess_number
        when Router::COMMANDS[:hint] then hint
        when Router::COMMANDS[:lose] then lose
        when Router::COMMANDS[:win] then win
        else respond(PAGES[:game])
        end
      rescue CodebreakerGem::Error::OnlyNumbers, CodebreakerGem::Error::InputRange,
             CodebreakerGem::Error::MaxStringLength => e
        assign_errors(e)
      end

      private

      def guess_number
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
        respond(PAGES[:win])
      end

      def lose
        return respond(:game) if game_exist? && !@game.lose?

        @request.session.clear
        respond(PAGES[:lose])
      end

      def no_match_result
        @request.session[:result] = @guess_result
        respond(PAGES[:game])
      end

      def hint
        @hints = @request.session[:hint_code] || []
        if @game.user_hints.positive?
          @hints << @game.use_hint
          @request.session[:hint_code] = @hints
        end
        respond(PAGES[:game])
      end

      def game_exist?
        @request.session[:game]
      end

      def assign_errors(error)
        @errors << error.message
        respond(PAGES[:game])
      end
    end
  end
end
