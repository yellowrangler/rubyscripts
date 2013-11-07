#!/usr/bin/env ruby
class sleepService

	def initialize(seconds)
		if seconds
			@time = seconds
		else
			@time = 5
		end		
	end

	def doSleep
		sleep @time
	end
	
end	