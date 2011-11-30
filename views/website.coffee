class ProgressBar
	constructor: (@el, @totalMilis, @interval) ->
		numberOfIntervals = @totalMilis / @interval
		@sizePerTick = 100 / numberOfIntervals
		
	tick: (milis) ->
		size = @percent(milis)
		@el.addClass("roundRight") if size > 99
		@el.width("#{size}%")
	
	percent: (milis)->
		milisPassed = @totalMilis - milis
		ticksPassed = milisPassed/@interval
		@sizePerTick * ticksPassed
		

class Timer
	constructor: (@el, @totalMilis, @timerDelay = 1000 * 60) ->
		@el.hide()
		@quarter = @totalMilis/4

	tick: (milis) ->
		return if milis % 1000 > 0 
		@update(milis)
		@show() if @shouldShow(milis)

	update: (milis) ->
		m = @td(@minsLeft(milis))
		s = @td(@secsLeft(milis))
		@el.text("#{m}:#{s}")
	
	show: ->
		@el.slideDown(600).delay(@timerDelay).slideUp(600)
	
	shouldShow: (milis) ->
		milis == @quarter || milis == @quarter*2 || milis == @quarter*3 || milis < @timerDelay

	td: (d) =>
		return "0#{d}" if d.toString().length < 2
		d	
	
	minsLeft: (milis)->
		Math.floor(milis / 1000 / 60)
	secsLeft: (milis)->
		(milis / 1000) % 60
	

class Slideshow
	constructor: (@el, @timePerSlide = 5000) ->
		@alarmTemplate = $("#alarm").html()
		@numberOfSlides = @el.find('.text').length
		@idx = 0 
		window.channel.bind('stop_alarm', => 
			@stop_alarm()
		)

	tick: (milis) ->
		return if milis % @timePerSlide > 0 
		@currentSlide().fadeOut(1000, 
			=>
				@nextSlide().fadeIn(1000)
		)
	
	firstSlide: ->
		$(@el.find(".text")[0])

	currentSlide: ->
		$(@el.find(".text")[@idx])

	nextSlide: ->
		@idx += 1
		@idx = 0 if @idx == @numberOfSlides 
		@currentSlide()
		
	playAlarm: ->
		iframe = $(@alarmTemplate)
		iframe.attr("src","http://www.youtube.com/watch_popup?v=#{currentSession.alarm}&autoplay=1&iv_load_policy=3&version=3")
		@el.empty().append(iframe)
	
	stop_alarm: ->
		@el.empty()


class Session
	constructor: (@el, @secondsLeft, @totalSeconds, @interval = 10) ->
		@ui =
			progressBar: @el.find(".pb-size")
			timer: @el.find(".timer_overlay")
			slideshow: @el.find(".text_area")
			deleteCode: @el.find(".delete_code")
		@totalMilis = @totalSeconds * 1000

		@components = [
			new ProgressBar(@ui.progressBar, @totalMilis, @interval),
			new Timer(@ui.timer, @totalMilis),
			new Slideshow(@ui.slideshow)
		]
		
		@milis = @secondsLeft * 1000
		@ui.deleteCode.hide()


		@intervalObj = setInterval(
			=> @tick()
			@interval
			)
	tick: ->
		@milis -= @interval
		@end() if @milis < 0 
		@update()

	update: ->
		for comp in @components
			comp.tick(@milis) 

	end: ->
		@milis = 0
		clearInterval(@intervalObj)
		console.log("END")
		@ui.deleteCode.show()
		_.last(@components).playAlarm()
		

class Raffle
	constructor: (el = $(".raffle"), @timeToEnd=1000, @interval=50) ->
		@el = $(el)
		window.channel.bind('raffle', => 
			@start()
		)

	start: ->
		won = @el.find("li.won") 
		if won.length > 0
			won.fadeOut(600, => won.remove();@startShuffling())
		else
			@startShuffling()

	startShuffling: ->
		console.log("Everyday I'm shuffling")
		@el.find("li").removeClass("selected").removeClass("won").removeClass("lost")
		setTimeout( 
			=> @end()
			@timeToEnd
		)
		@intervalEl = setInterval(
			=> @tick()
			@interval
		)
	tick: ->
		newSelected = $(_.shuffle(@notSelected())[0])
		@selected().removeClass("selected")
		newSelected.addClass("selected")

	end: ->
		@notSelected().addClass("lost")
		@selected().removeClass("selected").addClass("won")
		clearInterval(@intervalEl)
	selected: ->
		@el.find("li.selected")
	notSelected: ->
		@el.find("li:not(.selected)")

class Dashboard 
	constructor: ->
		@el = $('.page')
		@ui = 
			textArea : @el.find('.text_area')
			sessionCounter: @el.find('.session-counter')

	show: (@currentSession) ->
		@ui.sessionCounter.empty()
		@ui.textArea.empty()

		switch @currentSession.type
			when "text" then @gotoText()
			when "session" then @gotoSession()
			when "raffle" then @gotoRaffle()
		
	gotoText: ->
		div = @template("#text")
		@ui.textArea.append(div)
		div.fadeIn()
	
	gotoSession: ->
		@ui.sessionCounter.append(@template("#session"))
		@ui.textArea.append(@template("#ideas").show())
		for page in @currentSession.pages
			@ui.textArea.append(@template("#text", page))
		new Session(@el, @currentSession.secondsLeft, @currentSession.totalSeconds)
	
	gotoRaffle: ->
		raffle = @template("#raffle")
		@ui.textArea.append(raffle)
		new Raffle(raffle)

	template: (name, data = @currentSession)->
		$(_.template($(name).html(), data))
	

$().ready ->
	window.dashboard = new Dashboard()
	

	load_page = ->
		$.get('/current', (resp) ->
			window.dashboard.show(resp)
		)

	pusher = new Pusher('8e45d19d023a1fd74895')
	window.channel = pusher.subscribe('my_channel')
	window.channel.bind('next', -> 
		load_page()
	)

	window.dashboard.show(currentSession)

	