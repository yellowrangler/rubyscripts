#!/usr/bin/env ruby
require './HAmsgProcessingService'
require './HAfaxService'


logfile = "faxLogger"
logdirectory = "/data/fax/incoming/"
faxFileNameTest = "hafax"
faxFileNameBuild = "HA_"
faxDirectory "/data/fax/incoming/"
localDir = "data/"

#setup linux usb faxing
system ("./fax.sh")

# Send faxes to catcher server directory
msg = HAmsgProcessingService.new(logfile,logdirectory)
msg.processMsg("info", "log", "FAX Manager start")

#catch fax items
fax = HAfaxService.new(logfile,logdirectory,faxFileNameTest,faxFileNameBuild,faxDirectory)
fax.getFax

msg.processMsg("info", "log", "FAX Manager end\n")

