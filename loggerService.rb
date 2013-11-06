require 'rubygems'

class loggerService

	def initialize(logfilename)
		if logfilename != ""
			@logfile = logfilename
		else	
			@logfile = "log.txt"
		end	

		@logdirectory = "log"
		@fullyQualified = @logdirectory + "/" + @logfile
		@message = ""
		@file = ""
		@rec = ""
	end
	
	def openLog(access)
		@file = File.open(@fullyQualified, access)
	end
	
	def closeLog()
		@file.close unless @file == nil
	end

	def addEntry(smsg)
		openLog("a")
		@message = smsg

		currentTimestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")

		@rec = "SL~" + sprintf("%s~", currentTimestamp) + @message + "\n" 
		@file.puts(@rec) 
		closeLog()
	end

	def deleteLogFile()
		File.delete(@fullyQualified)
	end

	def getLastLog()
		openLog("r")

		@rec = @file.gets

		closeLog()
	end

	def getAllLogs()
		@rec = ""
		File.foreach(@fullyQualified) { |s|
		  @rec = @rec + s
		}

		closeLog()
	end
end