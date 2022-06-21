# frozen_string_literal: true

module Lib
  module Modules
    module WebHelper
      HAML_EXTENSION = '.html.haml'
      PATH_TO_VIEWS = './views'
      PAGES = {
        game: 'game',
        menu: 'menu',
        lose: 'lose',
        win: 'win',
        statistics: 'statistics',
        rules: 'rules',
        errors: 'errors'
      }.freeze

      def page_not_found
        Rack::Response.new(I18n.t(:page_not_found), 404)
      end

      def render_errors(template)
        render(PAGES[template.to_sym])
      end

      def respond(page)
        Rack::Response.new(render(PAGES[page.to_sym]))
      end

      def render(filename)
        path = File.read(full_path(filename))
        Haml::Engine.new(path).render(binding)
      end

      def full_path(filename)
        "#{File.join(PATH_TO_VIEWS, filename)}#{HAML_EXTENSION}"
      end
    end
  end
end
