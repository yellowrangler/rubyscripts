require 'rubygems'
require './gMailService'
require './loggerService'

class msgProcessingService

	def initialize()
		@msgType = ""
		@msgOption = ""		
		@log = loggerService.new
		@em = gMailService.new
		@msg = ""
	end
	  
	
	def processMsg(mtype, moption, msg)
		@msg = msg
		@msgType = mtype
		@msgOption = moption				
			
		case @msgType
		when 'info'
			processInfo
		when 'error'
			processErr	
		else
			@msg = "Unknown msg type: #{mtype}"
			@msgOption = "severe"
			processErr
		end
	end	# end of def 
	
	def processInfo
		case @msgOption
		when 'console'
			processConsole
		when 'log'
			processLog
		when 'infoLog'
			processConsole	
			processLog
		when 'mail'
			processMail
		when 'allInfo'
			processConsole	
			processLog
			processMail
		end	
	end	# end of def 
	
	def processConsole
		puts  @msg
	end	# end of def 
	
	
	def processLog
		@log.addEntry(@msg)
	end	# end of def 
	
	def processMail
		@em.sendMessage(@msg)
	end	# end of def 
	
	def processErr
		processLog
		processMail
		processConsole
		
		case @msgOption
		when 'severe'
			abort
		end	
	end	# end of def 
  
end  # end of class
