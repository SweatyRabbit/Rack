# frozen_string_literal: true

module Lib
  module Entities
    class Menu
      include Lib::Modules::WebHelper

      def self.call(env)
        new(env).response
      end

      def initialize(request)
        @request = request
        @errors = []
      end

      def response
        case @request.path
        when Lib::Entities::Router::COMMANDS[:menu] then menu_page
        when Lib::Entities::Router::COMMANDS[:statistics] then statistics_page
        when Lib::Entities::Router::COMMANDS[:rules] then rules_page
        when Lib::Entities::Router::COMMANDS[:game] then game_page
        else respond(:menu)
        end
      end

      private

      def menu_page
        @request.session.clear

        respond(:menu)
      end

      def statistics_page
        respond(:statistics)
      end

      def rules_page
        respond(:rules)
      end

      def game_page
        @name = @request.params['player_name']
        @difficulty = @request.params['level']
        @game = CodebreakerGem::Entities::Game.new(@name, @difficulty)
        @request.session[:game] = @game
        respond(:game)
      rescue CodebreakerGem::Error::NameLength, CodebreakerGem::Error::DifficultyHandler => e
        assign_errors(e)
      end

      def assign_errors(error)
        @errors << error.message
        respond(:menu)
      end
    end
  end
end
