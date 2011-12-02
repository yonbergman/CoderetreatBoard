require 'sinatra'
require 'sass'
require 'json'
require 'pusher'
require './phases'

Pusher.app_id = ENV['PUSHER_APP_ID']
Pusher.key = ENV['PUSHER_KEY']
Pusher.secret = ENV['PUSHER_SECRET']

phases_manager = Phases::Manager.new()

get '/' do
	haml :website, :format => :html5, :locals => {:session => phases_manager.current }
end

get '/current' do
	content_type :json
	phases_manager.current.to_json
end

get '/next' do
	phases_manager.next.to_json
end

get '/website.js' do
	coffee :website
end

get '/website.css' do
	scss :website
end

get '/remote' do
	haml :remote, :format => :html5, :locals => {:session => phases_manager.current}
end

get '/remote.js' do
	coffee :remote
end

get '/remote.css' do
	scss :remote
end

post '/stop' do
	Pusher['my_channel'].trigger!('stop_alarm', {})
end

post '/go' do
	phases_manager.next()
	Pusher['my_channel'].trigger!('next',{})
end

post '/raffle' do
	Pusher['my_channel'].trigger!('raffle', {})
end

get '/reset' do
	content_type :json
	phases_manager.reset.to_json
end
