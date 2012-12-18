ENV['RACK_ENV'] ||= 'development'

require 'bundler'

Bundler.require

require 'rack'
require 'angular-seed'

class StrangeReloader
  def initialize(app)
    @app = app
  end

  def call(env)
    Mannschaft.reset! if ENV['RACK_ENV'] == 'development'
    @app.call(env)
  end
end

app = Rack::Builder.new do
  use StrangeReloader

  map '/backend' do
    run Mannschaft::Backend.new
  end

  run Angular::Seed::App.new
end

run app