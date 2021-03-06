# frozen_string_literal: true

source 'https://rubygems.org'
ruby '3.0.1'
gem 'rails'

gem 'barnes'
gem 'carrierwave'
gem 'cloudinary'
gem 'coffee-rails'
gem 'country_select'
gem 'devise'
gem 'erubis'
gem 'figaro'
gem 'httparty'
gem 'jquery-rails'
gem 'mini_magick'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-twitter'
gem 'pagseguro-oficial', git: 'https://github.com/celsoMartins/ruby', branch: 'sandbox-find-by-notification-code' # due to the BigDecimal error on pagseguro bank ticket (boleto)
gem 'pg'
gem 'rake'
gem 'rollbar'
gem 'sass'
gem 'sass-rails'
gem 'sidekiq'
gem 'sidekiq-limit_fetch'
gem 'will_paginate'
gem 'yui-compressor', require: 'yui/compressor'

group :development, :test do
  gem 'brakeman'
  gem 'bullet'
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'faker'
  gem 'parser'
  gem 'rails-controller-testing'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rake'
  gem 'rubocop-rspec'
  gem 'shoulda-matchers'
  gem 'simplecov', '~> 0.16.1'
  gem 'webmock'
end

group :development do
  gem 'annotate'
  gem 'rack-mini-profiler', require: false
  gem 'web-console'
end

group :test do
  gem 'rspec_junit_formatter'
end

group :production do
  gem 'puma'
  gem 'rails_12factor'
end
