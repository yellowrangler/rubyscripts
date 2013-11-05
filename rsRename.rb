#!/usr/bin/env ruby

#rename file 
currentTimestamp = Time.now.strftime("%Y-%m-%d-%H.%M.%S")
directory = "/home/tarryc/"
fromfile = "testrename"
tofile = fromfile + currentTimestamp
File.rename(directory+fromfile, directory+tofile)
