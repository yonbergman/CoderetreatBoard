require 'sinatra'
require 'sass'
require 'json'
require 'pusher'

Pusher.app_id = ENV['PUSHER_APP_ID']
Pusher.key = ENV['PUSHER_KEY']
Pusher.secret = ENV['PUSHER_SECRET']

TIME_PER_SESSION = 90 #* 60 #45mins

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
	"alon",
	"stanislav",

	"danni",
	"herve",
	"yoavtz",
	"ron",
	"antmir"
].shuffle()

def create_session(id)
pages = [
	{ :header => "Game of Life Rules", :text => <<-eos
      <ul>
        <li>A live cell remains alive only if it has 2-3 live neighbours</li>
        <li>A dead cell becomes alive only if it has <strong>exactly</strong> live neighbours</li>
      </ul>
      eos
    },
	{ :header => "SOLID", :text => <<-eos
      <ul>
        <li><strong>S</strong>: Single Responsibility Principle</li>
        <li><strong>O</strong>: Open-Closed Principle</li>
        <li><strong>L</strong>: Liskov Substitution Principle</li>
        <li><strong>I</strong>: Interface Segregation Principle</li>
        <li><strong>D</strong>: Dependency Inversion Principle</li>
      </ul>
    eos
    },
    { :header => "DRY", :text => <<-eos
      <img src="http://img443.imageshack.us/img443/385/screenshot20111130at729.png">
    eos
    },
    { :header => "TDD", :text => <<-eos
      <h2>Test Driven Development</h2>
      <div style="color: red">RED</div>
      <div style="color: green">GREEN</div>
      <div style="color: red">REFACTOR</div>
    eos
    },
	{ :header => "4 Rules of Simple Design", :text => <<-eos
      <ol>
        <li>Works - Passes all the tests</li>
        <li>DRY - Minimizes duplication</li>
        <li>Expresses intent - Maximizes clarity</li>
        <li>Has fewer elements</li>
      </ol>
    eos
    },
	{ :header => "Hey! You holding the keyboard!", :text => <<-eos
      <h2>Do you really think that's a descriptive variable name?</h2>
    eos
    },
	{ :header => "Hey! You holding the keyboard!", :text => <<-eos
      <h2>Have you ever heard of OOP? From the looks of your code, I think not!</h2>
    eos
    },
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


	{:type => 'session', :number => id+1, :ideas => ideas[id],:alarm => nyans[id], :pages => pages, :totalSeconds => TIME_PER_SESSION}
end

sessions = [
	{:type => 'text', :header => "Hello, World;", :text => "Enjoy Breakfast"},
	create_session(0),
	create_session(1),
	create_session(2),
	{:type => 'text', :header => "Lunch Time", :text => "Om nom, nom, nom <div><img src='http://nyan-cat.com/images/nyan-cat.gif'></div>"},
	create_session(3),
	create_session(4),
	create_session(5),
	{:type => 'raffle', :participants => participants},
	{:type => 'text', :header => "end();", :text => "Thanks for coming"}
]

current_session = 0

get '/' do
	session = sessions[current_session]
	if session['startTime']
		session[:secondsLeft] = (session['startTime'] + TIME_PER_SESSION - Time.now).floor
	end
	haml :website, :format => :html5, :locals => {:session => session }
end

get '/current' do
	content_type :json
	session = sessions[current_session]
	if session['startTime']
		session[:secondsLeft] = (session['startTime'] + TIME_PER_SESSION - Time.now).floor
	end
  	session.to_json
end

get '/next' do
	current_session += 1
	sessions[current_session]['startTime'] = Time.now if sessions[current_session][:type] == 'session'	
	"/"
end

get '/website.js' do
	coffee :website
end

get '/website.css' do
	# header 'Content-Type' => 'text/css; charset=utf-8'
	scss :website
end

get '/remote' do
	haml :remote, :format => :html5, :locals => {:session => sessions[current_session]}
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
	current_session += 1
	sessions[current_session]['startTime'] = Time.now if sessions[current_session][:type] == 'session'

	Pusher['my_channel'].trigger!('next',{})
end

post '/raffle' do
	Pusher['my_channel'].trigger!('raffle', {})
end



