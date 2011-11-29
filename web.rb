require 'sinatra'
require 'sass'



get '/' do
 haml :website, :format => :html5
end

get '/website.js' do
	coffee :website
end

get '/website.css' do
	# header 'Content-Type' => 'text/css; charset=utf-8'
	scss :website
end
