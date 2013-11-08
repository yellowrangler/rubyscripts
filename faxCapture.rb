#!/usr/bin/env ruby
require './HAmsgProcessingService'
require './HAfaxService'

#set up globals parms
logfile = "faxLogger"
logdirectory = "/data/fax/incoming"
faxFileNameTest = "hafax"
faxFileNameBuild = "HA_"
faxDirectory = "/data/fax/incoming/"

# Start the fax capture service. This service will start efax which will wait for fax.
# After fax is collected files will be renamed and logs written

#run script to setup usb modem
system ("./fax.sh")

#start fax capture
msg = HAmsgProcessingService.new(logfile,logdirectory)
msg.processMsg("info", "log", "Fax Manager start")

#end of fax capture
fax = HAfaxService.new(logfile,logdirectory,faxFileNameTest,faxFileNameBuild,faxDirectory)
fax.getFax



