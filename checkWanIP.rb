#!/usr/bin/env ruby

# require 'rubygems'
require 'net/http'

require '/home/tarryc/Development/rubyScripts/SendgMail'

# First we get the current WAN IP
uri = URI('http://www.myexternalip.com/raw')
currentwanip = Net::HTTP.get(uri)

#We get the previous WAN IP
input = File.open('/home/tarryc/Development/rubyScripts/currentwanip.txt','rt')  
previouswanip = input.read() 
input.close 

#Compare the previous WAN IP to current
if currentwanip.chop != previouswanip.chop
    # send email to me if mismatch
    mail = SendgMail.new
    msg = "Previous wanip: " + previouswanip + " New wanip:" + currentwanip

    mail.sendMessageGmail(msg)

    # write new wanip to file
    output = File.open('/home/tarryc/Development/rubyScripts/currentwanip.txt' , 'w')
    output.write(currentwanip) 
    output.close 
end