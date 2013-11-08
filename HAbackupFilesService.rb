#!/usr/bin/env ruby
require 'fileutils'
require './HAmsgProcessingService'

class HAbackupFilesService

	def initialize(logfile,logdirectory,fileName,fromDirectory,toDirectory)
		@logfile = logfile
		@logdirectory = logdirectory
		@msg = HAmsgProcessingService.new(@logfile,@logdirectory)		

		@fileName = fileName
		@fromDirectory = fromDirectory
		@toDirectory = toDirectory
	end

	def backupFiles
		@msg.processMsg("info", "log", "Started backup process")

		fileArray = Dir.glob(@fromDirectory+@fileName+"*")

		fileno = 0
		fileArray.each do |fromfile|
			tofilebase = File.basename(fromfile)
			tofile = @toDirectory+tofilebase
			FileUtils.mv(fromfile, tofile)

			#delete file if exists
			if File.exist?(fromfile)
				File.unlink(fromfile)
			end

			#log the event
			@msg.processMsg("info", "log", "Backed up #{tofilebase}")

			fileno = fileno + 1
		end
		
		@msg.processMsg("info", "log", "End of backup. Total files = #{fileno.to_s}")
	end
end

