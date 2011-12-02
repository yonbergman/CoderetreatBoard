require 'json'

module Phases
	require './config/ideas'
	require './config/alarms'
	require './config/content'
	require './config/participants'

	class Manager
		def initialize()
			@phases = [
				Text.new(TEXT_SLIDES[:morning]),
				Session.new(1),
				Session.new(2),
				Session.new(3),
				Text.new(TEXT_SLIDES[:afternoon]),
				Session.new(4),
				Session.new(5),
				Session.new(6),
				Raffle.new(),
				Text.new(TEXT_SLIDES[:end])
			]
			reset()
		end

		def current
			@phases[@current_idx]
		end

		def next
			return nil if last_phase?
			goto(@current_idx + 1)
		end

		def reset
			goto(0)
		end

		private

		def goto(idx)
			@current_idx = idx
			current.start()
		end


		def last_phase?
			@current_idx >= @phases.length - 1
		end

	end

			
	class Base
		def initialize(type, data)
			@type = type
			@data = data
		end

		def to_json(more_data = {})
			d = @data
			d.merge!(:type => @type)
			d.merge!(more_data)
			d.to_json
		end

		def start
			self
		end

	end

	class Session < Base
		TIME_PER_SESSION = 45 * 60 #45mins
	
		def initialize(number, time_per_session = TIME_PER_SESSION)
			data = {
				:number => number,
				:pages => PAGES,
				:ideas => IDEAS[number-1],
				:alarm => ALARMS[number-1],
				:totalSeconds => time_per_session,
			}
			super(:session, data)
		end

		def start
			@data[:startTime] = Time.now
			super
		end

		def to_json
			more_data = {}
			more_data[:secondsLeft] = (@data[:startTime] + @data[:totalSeconds] - Time.now).floor if @data[:startTime]
			super(more_data)
		end
	end


	class Raffle < Base
		def initialize()
			super(:raffle, :participants => PARTICIPANTS)
		end
	end

	class Text < Base
		def initialize(text_slide)
			super(:text, text_slide)
		end
	end

end