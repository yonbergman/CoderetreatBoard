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
		@start()

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
		setTimeout(
			=> @start()
			2000
			)
	selected: ->
		@el.find("li.selected")
	notSelected: ->
		@el.find("li:not(.selected)")
	

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
		new Session($(".page"),currentSession.secondsLeft,currentSession.totalSeconds)
		#new Session($(".page"),45,60)
	else if currentSession.type == "raffle"
		$('.text_area').append($(_.template($("#raffle").html(), currentSession)))
		new Raffle($('.raffle'))