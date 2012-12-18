module Mannschaft
  def self.load!
    Dir[File.expand_path('../mannschaft/**/*.rb', __FILE__)].each {|f| load f}
  end

  def self.reset!
    Backend.reset!
    load!
  end
end

require 'mongoid'

require 'mannschaft/version'
Mannschaft.load!

ENV['RACK_ENV'] ||= 'development'
Mongoid.load!(File.expand_path("../../config/mongoid.yml", __FILE__))