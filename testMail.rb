require 'rubygems'
require '~/Development/RubyMySQLProject/classes/SendgMail'
require '~/Development/RubyMySQLProject/classes/Logger'

mail = SendMail.new
log = Logger.new("mytest")

msg = "This is a test"

mail.sendMessageGmail(msg)
log.addEntry("Sent email successfully")
