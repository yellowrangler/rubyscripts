#!/usr/bin/env ruby
require './ServiceLogger'
# require 'fileutils'

#This will rename with date time and then move a file to path
file = ARGV[0]
path = ARGV[1]

#rename file 
currentTimestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
filename = file + currentTimestamp
File.rename(file, filename)

#move the file
fromfile = filename
tofile = path + filename
FileUtils.mv(fromfile, tofile)	

#log the file 
faxlog = ServiceLogger.new("faxLogger")
faxlog.addEntry("Fax Created for "+tofile)