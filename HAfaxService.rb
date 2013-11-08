#!/usr/bin/env ruby
require './HAmsgProcessingService'
# require 'fileutils'

class HAfaxService

	def initialize(logfile,logdirectory,faxFileNameTest,faxFileNameBuild,faxDirectory)
		@logfile = logfile
		@logdirectory = logdirectory
		@msg = HAmsgProcessingService.new(@logfile,@logdirectory)		

		@faxFileNameTest = faxFileNameTest
		@faxFileNameBuild = faxFileNameBuild
		@faxDirectory = faxDirectory

		@wait = 5
	end

	def getFax
		@msg.processMsg("info", "log", "Started fax process")

		faxNo = faxLoop(0)
		while faxNo > 0 && runLoopCheck
			@msg.processMsg("info", "", "Start faxLoop while. Nbr = #{faxNo.to_s}")	
			faxNo = faxLoop(faxNo)	
		end
		
		@msg.processMsg("info", "log", "End of faxLoop. Total Nbrs = #{faxNo.to_s}")
	end

	#This will run the fax service
	def faxLoop(nbr)
		system 'killall efax'
		
		sysCmdStr = "efax -d /dev/ttyS3 -r #{@faxDirectory}#{@faxFileNameTest} -w -iS0=3 2>&1 >> #{@faxDirectory}fax.log"
		system sysCmdStr

		#rename file 
		renameFiles()

		#sleep to give efax chance to clear out
		sleep @wait

		return nbr + 1
	end

	#This will look up a file to see if service should continue to be run
	def runLoopCheck
		#We check to see if we should continue to run
		input = File.open('faxService.txt','rt')  
		faxrecord = input.read() 
		input.close 

		if faxrecord.chop == "true"
			rv = true
		else
			rv = false
		end
		
		return rv		
	end

	#This will rename with date time 
	def renameFiles () 
		fromfile = @faxFileNameTest
		directory = @faxDirectory

		currentTimestamp = Time.now.strftime("%Y-%m-%d-%H-%M-%S")
		tofileBase = @faxFileNameBuild + currentTimestamp
		faxfileArray = Dir.glob(directory+fromfile+"*").sort_by{|f| File.mtime(f) }

		i = 1
		faxfileArray.each do |faxFile|
			# puts "working on: #{faxFile}"
			tofileExtention = File.extname(faxFile)
			# tofile = directory+tofileBase+"_"+i.to_s.rjust(5,'0')+tofileExtention
			tofile = directory+tofileBase+tofileExtention+".tiff"
			File.rename(faxFile, tofile)

			#delete file if exists
			if File.exist?(faxFile)
				File.unlink(faxFile)
			end

			#log the event
			@msg.processMsg("info", "log", "Fax Created for #{tofile}")

			i = i + 1
		end

		@msg.processMsg("info", "log", "Fax Pages Created for #{tofileBase} = #{(i-1).to_s}")
	end

end

