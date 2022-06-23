# frozen_string_literal: true

module Lib
  module Entities
    class Router
      include Lib::Modules::WebHelper

      COMMANDS = {
        menu: '/',
        game: '/game',
        rules: '/rules',
        hint: '/hint',
        win: '/win',
        lose: '/lose',
        statistics: '/statistics',
        guess: '/guess'
      }.freeze

      def self.call(env)
        new(env).response.finish
      end

      def initialize(env)
        @env = env
        @request = Rack::Request.new(env)
      end

      def response
        return page_not_found unless COMMANDS.value?(@request.path)

        @request.session[:game] ? Lib::Entities::Game.call(@request) : Lib::Entities::Menu.call(@request)
      end
    end
  end
end
