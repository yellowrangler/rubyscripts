#!/usr/bin/env ruby
require './ServiceLogger'
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
	currentTimestamp = Time.now.strftime("%Y-%m-%d-%H.%M.%S")
	fromfile = logfile
	tofile = fromfile + currentTimestamp
	File.rename(logdirectory+fromfile, logdirectory+tofile)

	#log the file 
	faxlog = ServiceLogger.new("faxLogger")
	faxlog.addEntry("Fax Created for "+tofile)
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
	faxlog = ServiceLogger.new("faxLogger")
	faxlog.addEntry("Started fax process")
	faxNo = faxLoop(0)
	while faxNo > 0 && runLoopCheck
		faxlog.addEntry("Start faxLoop while. Nbr = "+faxNo.to_s)		
		faxNo = faxLoop(faxNo)
		faxlog.addEntry("End faxLoop while. Nbr = "+faxNo.to_s)		
	end
	
	faxlog.addEntry("End of faxLoop. Total Nbrs = "+faxNo.to_s+"\n")	
end

