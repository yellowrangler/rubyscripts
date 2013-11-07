#!/usr/bin/env ruby
require './HAmsgProcessingService'
require './HAfaxService'
# require 'fileutils'

# Start the fax service. This service will start efax whciwill wait for fax.
# After fax is collected files will be renamed and logs written
begin
	system ("./fax.sh")
	msg = HAmsgProcessingService.new("faxLogger","log")
	msg.processMsg("info", "log", "Fax Manager start")

	fax = HAfaxService.new()
	fax.getFax
	
	msg.processMsg("info", "log", "Fax Manager end\n")
end

