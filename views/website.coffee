Page = Backbone.Model.extend
	initialize: (el,time, @interval = 10) ->
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

$().ready =>
	new Page($('.page'),1)