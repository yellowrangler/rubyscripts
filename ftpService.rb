require 'rubygems'
require 'dbi'
require 'net/http'
require 'net/ftp'
require 'uri'
require 'xmlsimple'
require 'json'
require './msgProcessingService'

class ftpService
	
	def initialize(ftpip, remotedir, ftpfilename, ftpuser, ftppassword)
		@ftpIP = ftpip
		@remoteDir = remotedir
		@ftpfilename = ftpfilename
		@ftpUser = ftpuser
		@ftpPassword = ftppassword
		@historyDir = "history"
		
		@msg = msgProcessingService.new()
	end

	def doPush
		begin
		ftp = Net::FTP.new(host = @ftpIP)
		ftp.login(user = @ftpUser, passwd = @ftpPassword)
		ftp.chdir(@remoteDir)
		ftp.puttextfile(@ftpfilename, remotefile = File.basename(@ftpfilename))
		ftp.close
		
		renameFTPfile
		rescue
		msgStr = "FTP failed on push. file =  #{@ftpfilename}.  Error #{$!}"
		@msg.processMsg("error", "severe", msgStr)
		end
	end	
	
	def doGet
		begin
		ftp = Net::FTP.new(host = @ftpIP)
		ftp.login(user = @ftpUser, passwd = @ftpPassword)
		ftp.chdir(@remoteDir)
		ftp.gettextfile(@ftpfilename, remotefile = File.basename(@ftpfilename))
		ftp.close
		rescue 
		msgStr = "FTP failed on get. file =  #{@ftpfilename}.  Error #{$!}. Host = #{@ftpIP} User = #{@ftpUser} Password = #{@ftpPassword}"
		@msg.processMsg("error", "severe", msgStr)
		end
	end	
	
	def getFileName
		@ftpfilename
	end	
	
	def renameFTPfile
		currentTimestamp = Time.now.strftime("%Y%m%d%H%M%S")
		
		input = File.open(@ftpfilename)  
		data_to_copy = input.read()  
		newFile = @historyDir + "/" + currentTimestamp + "_" + @ftpfilename 
		output = File.open(newFile , 'w')
		output.write(data_to_copy)  
		#File.rename(@ftpfilename, @ftpfilename + currentTimestamp.to_s)	
	end
	
 end
