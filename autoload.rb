# frozen_string_literal: true

require 'rack'
require 'pry'
require 'haml'
require 'i18n'
require 'bundler/setup'
require 'faker'
require 'codebreaker_gem'

require_relative('lib/config/i18n_config')
require_relative('lib/modules/web_helper')
require_relative('lib/entities/menu')
require_relative('lib/entities/game')
require_relative('lib/entities/router')
