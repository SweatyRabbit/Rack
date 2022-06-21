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
        when Router::COMMANDS[:menu] then menu_page
        when Router::COMMANDS[:statistics] then statistics_page
        when Router::COMMANDS[:rules] then rules_page
        when Router::COMMANDS[:game] then game_page
        else respond(menu)
        end
      rescue CodebreakerGem::Error::NameLength, CodebreakerGem::Error::DifficultyHandler => e
        assign_errors(e)
      end

      private

      def menu_page
        respond(PAGES[:menu])
      end

      def statistics_page
        respond(PAGES[:statistics])
      end

      def rules_page
        respond(PAGES[:rules])
      end

      def game_page
        @name = @request.params['player_name']
        @difficulty = @request.params['level']
        @game = CodebreakerGem::Entities::Game.new(@name, @difficulty)
        @request.session[:game] = @game
        respond(PAGES[:game])
      end

      def assign_errors(error)
        @errors << error.message
        respond(PAGES[:menu])
      end
    end
  end
end
