#!/usr/bin/env ruby

#rename file 
currentTimestamp = Time.now.strftime("%Y-%m-%d-%H-%M-%S")
fromdirectory = "/home/tarryc/Development/rubyScripts/data/"
fromfile = "test"
todirectory = "/home/tarryc/Development/rubyScripts/log/"
tofile = ""

faxfileArray = Dir.glob(fromdirectory+fromfile+"*").sort_by{|f| File.mtime(f) }

i = 1
faxfileArray.each do |faxFile|
	puts "working on: #{faxFile}"
	tofile = fromfile + currentTimestamp
	tofileExtention = File.extname(faxFile)
	File.rename(faxFile, todirectory+tofile+"_"+i.to_s.rjust(5,'0')+tofileExtention)
	i = i + 1
end
# tofile = fromfile + currentTimestamp
# File.rename(directory+fromfile, directory+tofile)
