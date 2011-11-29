require 'sinatra'
require 'sass'
require 'json'

participants = [
	"abyx",
	"yon",
	"erez",
	"erik",
	"yonix",

	"roey",
	"s_ageev",
	"avihut",
	"shmef",
	"uri.s",

	"iftach",
	"3david",
	"amirwilf",
	"noamgat",
	"itay",

	"sheba",
	"guy",
	"yulkes", #
	"alon",
	"stanislav",

	"danni",
	"herve",
	"yoavtz",
	"ron",
	"antmir"
].shuffle()

pages = [
	{ :header => "Game of Life", :text => "rules are here blah blah <br> blah"},
	{ :header => "S.O.L.I.D", :text => "Solid is good for you"}
]

ideas = [
	["Regular","TDD"],
	["No Primitives","Yes, And"],
	["Polymorphism", "No mouse", "TDD as if"],
	["Event Based", "3D World", "Evil mute programmer"],
	["No Testing"],
	["Infinite Universe"]
]

nyans = [
	"QH2-TGUlwu4", #regular
	"AaEmCFiNqP0", #jazz
	"YsDab6JjXJg", #ascii

	"OM-9Q0ac6Zs", #evil
	"48GEvJLJoI4", #old
	"EUgTHYFJfDM", #Jewish
]

sessions = [
	{:type => 'text', :header => "Welcome", :text => "Enjoy Breakfast"},
	{:type => 'session', :number => 1, :ideas => ideas[0],:alarm => nyans[0], :pages => pages},
	{:type => 'session', :number => 2, :ideas => ideas[1],:alarm => nyans[1], :pages => pages},
	{:type => 'session', :number => 3, :ideas => ideas[2],:alarm => nyans[2], :pages => pages},
	{:type => 'text', :header => "Lunch Time", :text => "Om nom, nom, nom <div><img src='http://nyan-cat.com/images/nyan-cat.gif'></div>"},
	{:type => 'session', :number => 4, :ideas => ideas[3],:alarm => nyans[3], :pages => pages},
	{:type => 'session', :number => 5, :ideas => ideas[4],:alarm => nyans[4], :pages => pages},
	{:type => 'session', :number => 6, :ideas => ideas[5],:alarm => nyans[5], :pages => pages},
	{:type => 'raffle', :participants => participants},
	{:type => 'text', :header => "Bye", :text => "Thanks for coming"}
]

current_session = 0

get '/' do
	haml :website, :format => :html5, :locals => {:session => sessions[current_session]}
end

get '/current' do
	content_type :json
  	sessions[current_session].to_json
end

get '/next' do
	current_session += 1
	sessions[current_session]['startTime'] = Time.now if sessions[current_session][:type] == 'session'
	haml :website, :format => :html5, :locals => {:session => sessions[current_session]}
end

get '/website.js' do
	coffee :website
end

get '/website.css' do
	# header 'Content-Type' => 'text/css; charset=utf-8'
	scss :website
end

get '/remote' do
	st = sessions[current_session]['startTime']
	if !st.nil?
		@st = st
		time_left = (st+45*60) - Time.now
		@seconds_left = (time_left % 60).floor
		@minutes_left = (time_left/60).floor
	end
	haml :remote, :format => :html5, :locals => {:session => sessions[current_session]}
end

get '/remote.js' do
	coffee :remote
end

get '/remote.css' do
	scss :remote
end
