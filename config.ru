# This file is used by Rack-based servers to start the application.

require 'rubygems'
require 'bundler'
Bundler.setup
require './web'
run Sinatra::Application