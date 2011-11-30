class Timer
	constructor: (@el) ->
		@ui =
			timer: @el.find('.timer').hide()
			name: @el.find('.session_name')
			buttons : 
				go: @el.find(".go").show()
				nyan: @el.find(".nyan").hide()
				raffle: @el.find(".raffle").hide()
		
		@ui.buttons.go.click ->  $.post('/go') ; $(@).addClass('ui-disabled') 
		@ui.buttons.nyan.click -> $.post('/stop') ; $(@).addClass('ui-disabled')  
		@ui.buttons.raffle.click -> 
			$.post('/raffle')
			$(@).addClass('ui-disabled')
			setTimeout(
				=> $(@).removeClass('ui-disabled')
				1000
			)

	setSession: (@secondsLeft, @session) ->
		@setSessionName()
		@ui.buttons.go.show()
		if @session.type == "session"
			@ui.timer.show()
			@ui.buttons.nyan.show()
			@ui.buttons.raffle.hide()
		else if @session.type == "raffle"
			@ui.timer.hide()
			@ui.buttons.nyan.hide()
			@ui.buttons.raffle.show()
		else
			@ui.timer.hide()
			@ui.buttons.nyan.hide()
			@ui.buttons.raffle.hide()
		@startTimer() if @secondsLeft?
		
	startSync: ->
		clearInterval(@timeSyncInterval) if @timeSyncInterval?
		@timeSyncInterval = setInterval(
			=> @sync()
			5000
			)

	sync: ->
		$.get('/current?' + Math.random().toString(), (data) =>
			@secondsLeft = data.secondsLeft
		)
		

	startTimer: ->
		if @secondsLeft > 0
			@disableButtons()
			@update()
			@startSync()
			@interval = setInterval(
				=> @tick()
				1000
			)
		else
			@update()
			@ended()
	
	ended: ->
		@enableButtons()

	tick: ->
		@secondsLeft -= 1
		if @secondsLeft == 0
			clearInterval(@interval)
			clearInterval(@timeSyncInterval) if @timeSyncInterval?
			@ended()
		@update()

	update:  ->
		m = @td(@minsLeft())
		s = @td(@secsLeft())
		@ui.timer.text("#{m}:#{s}")

	td: (d) =>
		return "0#{d}" if d.toString().length < 2
		d	
	
	minsLeft: ->
		Math.floor(@secondsLeft / 60)
	secsLeft: ->
		@secondsLeft % 60
	
	disableButtons: ->
		@el.find('.button').addClass('ui-disabled')
	enableButtons: ->
		@el.find('.button').removeClass('ui-disabled')

	setSessionName: ->
		name = "session ##{@session.number}" if @session.type == "session"
		name = @session.header if @session.type == "text"
		name = "raffle" if @session.type == "raffle"
		@ui.name.text(name)


$().ready(->
	window.remote = new Timer($('page'))
	load_page = =>
		$.get('/current?' + Math.random().toString(), (resp) ->
			window.remote.setSession(Math.max(0,resp.secondsLeft),resp)
		)

	pusher = new Pusher('8e45d19d023a1fd74895')
	channel = pusher.subscribe('my_channel')
	channel.bind('next', (data) -> 
		load_page()	
	)
	load_page()
)