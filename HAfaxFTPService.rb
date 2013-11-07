#!/usr/bin/env ruby
require './HAloggerService'
# require 'fileutils'

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
def renameFiles (logfile, logdirectory) 
	currentTimestamp = Time.now.strftime("%Y-%m-%d-%H-%M-%S")
	fromfile = logfile
	tofileBase = fromfile + currentTimestamp
	faxfileArray = Dir.glob(logdirectory+fromfile+"*").sort_by{|f| File.mtime(f) }
	
	#instantiate the logger 
	faxlog = loggerService.new("faxLogger")

	i = 1
	faxfileArray.each do |faxFile|
		# puts "working on: #{faxFile}"
		tofileExtention = File.extname(faxFile)
		tofile = logdirectory+tofile+"_"+i.to_s.rjust(5,'0')+tofileExtention
		File.rename(faxFile, tofile)

		#log the event
		faxlog.addEntry("Fax Created for "+tofile)

		i = i + 1
	end

	
	faxlog.addEntry("Fax Pages Created for "+tofileBase+" = "+(i-1).to_s)
end

#This will run the fax service
def faxLoop(nbr)
	system 'killall efax'
	system 'efax -d /dev/ttyS3 -r "/data/fax/incoming/hafax" -w -iS0=3 2>&1 >> /data/fax/incoming/fax.log'

	#rename file 
	renameFiles("hafax", "/data/fax/incoming/")

	#sleep to give efax chance to clear out
	system './faxSleep.rb'

	return nbr + 1
end

#This is main routine
begin
	faxlog = loggerService.new("faxLogger")
	faxlog.addEntry("Started fax process")
	faxNo = faxLoop(0)
	while faxNo > 0 && runLoopCheck
		faxlog.addEntry("Start faxLoop while. Nbr = "+faxNo.to_s)		
		faxNo = faxLoop(faxNo)
		faxlog.addEntry("End faxLoop while. Nbr = "+faxNo.to_s)		
	end
	
	faxlog.addEntry("End of faxLoop. Total Nbrs = "+faxNo.to_s)	
end

