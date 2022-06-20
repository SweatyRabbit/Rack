# frozen_string_literal: true

require_relative 'autoload'
require 'delegate'

use Rack::Static, urls: ['/assets'], root: 'views'
use Rack::Session::Cookie, key: 'rack.session', secret: 'secret'
use Rack::Reloader, 0

run Lib::Entities::Router
