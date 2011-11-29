Page = Backbone.Model.extend
	initialize: (el = $('.page') ,time = 5, @interval = 10) ->
		@el = $(el)
		@ui = 
			progressBar: @el.find(".pb-size")
			timer: @el.find(".timer_overlay")
		@time = time
		@milis = time * 60 * 1000
		@current =
			minutes: @time
			seconds: 0
		@numberOfIntervals = @milis/@interval
		@sizePerTick = 100 / @numberOfIntervals
		@quarter = @numberOfIntervals/4*@interval
		@pbSize = 0
		@timerDelay = 5000

		@initTimer()
		@intervalObj = setInterval(
			=> @tick()
			@interval
			)

	tick: ->
		@milis -= @interval
		@end() if @milis < 0 
		@update()

	end: ->
		clearInterval(@intervalObj)
		console.log("END")
		@playAlarm()
	
	update: ->
		@updateProgressBar()		
		@updateTime()		
		@updateTextSlides()		
		
	updateProgressBar: ->
		@pbSize += @sizePerTick
		@ui.progressBar.addClass("roundRight") if @pbSize > 99
		@ui.progressBar.width("#{@pbSize}%")

	initTimer: ->
		@ui.timer.hide()
		@updateTimer()

	updateTime: ->
		return if @milis % 1000 > 0 
		@current.seconds -= 1
		if @current.seconds < 0
			@current.seconds = 59
			@current.minutes -= 1
			if @current.minutes < 0
				@timerEnd()
				return
		@updateTimer()
		@showTimer() if @shouldShowTimer()

	timerEnd: ->
		@current.seconds = 0
		@current.minutes = 0
		@ui.timer.addClass("ended")

	showTimer: ->
		@ui.timer.slideDown(600).delay(@timerDelay).slideUp(600)

	shouldShowTimer: ->
		@milis == @quarter || @milis == @quarter*2 || @milis == @quarter*3

	updateTimer: ->
		@ui.timer.text("#{@td(@current.minutes)}:#{@td(@current.seconds)}")

	td: (d) =>
		return "0#{d}" if d.toString().length < 2
		d

	updateTextSlides: ->
		return if @milis % 5000 > 0 
		currentText = $(".text:visible")
		next = currentText.next()
		currentText.fadeOut(1000, 
			=>
				next = $($('.text')[0]) if next.length == 0
				next.fadeIn(1000)
		)
	playAlarm: ->
		iframe = $($("#alarm").html())
		iframe.attr("src","http://www.youtube.com/watch_popup?v=#{currentSession.alarm}&autoplay=1&iv_load_policy=3&version=3")
		$('.text_area').empty().append(iframe)


Raffle =  Backbone.Model.extend
	initialize: (el = $(".raffle"), @timeToEnd=1000, @interval=50) ->
		@el = $(el)
		@start()

	start: ->
		if @el.find("li.won").length > 0
			@el.find("li.won").fadeOut(600, => @el.find("li.won").remove();@startShuffling())
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
		newSelected = $(_.shuffle(@el.find("li:not(.selected)"))[0])
		@el.find("li.selected").removeClass("selected")
		newSelected.addClass("selected")

	end: ->
		@el.find("li:not(.selected)").addClass("lost")
		@el.find("li.selected").removeClass("selected").addClass("won")
		clearInterval(@intervalEl)
		setTimeout(
			=> @start()
			2000
			)

	

$().ready =>
	if currentSession.type == "text"
		d = $(_.template($("#text").html(), currentSession))
		$(".text_area").append(d)
		d.fadeIn()
	else if currentSession.type == "session"
		$('.session-counter').append($(_.template($("#session").html(), currentSession)))
		ideasDiv = $(_.template($("#ideas").html(), currentSession))
		$('.text_area').append(ideasDiv)
		ideasDiv.show()
		for page in currentSession.pages
			$('.text_area').append($(_.template($("#text").html(), page)))
		new Page($(".page"),5)
	else if currentSession.type == "raffle"
		$('.text_area').append($(_.template($("#raffle").html(), currentSession)))
		new Raffle($('.raffle'))