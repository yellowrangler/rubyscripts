require 'rubygems'
require 'net/http'
require 'net/ftp'
require 'uri'
require 'net/smtp'

class SendgMail
	
	def initialize()
		@server = "smtp.gmail.com"
		@port = 587
		@sendTo = "tarrant.cutler@gmail.com"
		@sendFrom = "tarrant.cutler@gmail.com"
		@account = "tcutler.business@gmail.com"
		@msg = ""
		@accountPassword = "yellowrangler"	
	end
  
	def sendMessageGmail(smsg)
		@msg = smsg
 	begin
message = <<EOF
From: Turksandcaicos Server <#{@account}>
To: <#{@sendTo}>
Subject: Ruby generated email 

#{@msg}
EOF
 
#Using Block
smtp = Net::SMTP.new(@server, @port )
smtp.enable_starttls
 
smtp.start('gmail.com', @account, @accountPassword, :login) do |smtp|
        smtp.send_message message, @sendFrom, @sendTo 
end # end of do	
	rescue
	puts "SMTP failed.  Error #{$!}"	
	end # end of begin
	end	# end of def 
  
 end  # end of class
