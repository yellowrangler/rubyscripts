require 'rubygems'
require './HAgMailService'
require './HAloggerService'

class HAmsgProcessingService

	def initialize(logfile, logdirectory)
		@msgType = ""
		@msgOption = ""		
		if logfile
			@log = HAloggerService.new(logfile,logdirectory)
		else
			@log = HAloggerService.new("","")
		end	
		@em = HAgMailService.new
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
		@em.sendMessageGmail(@msg,"")
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
