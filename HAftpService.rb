require 'rubygems'
require 'dbi'
require 'net/http'
require 'net/ftp'
require 'uri'
require 'xmlsimple'
require 'json'
require './HAmsgProcessingService'

class HAftpService
	
	def initialize(ftpIP,localDir,ftpUser,ftpPassword,remoteDir,ftpfilename,historyfile,historyDir,logfile,logdirectory)
		@ftpIP = ftpIP
		@localDir = localDir
		@ftpUser = ftpUser
		@ftpPassword = ftpPassword
		@remoteDir = remoteDir
		@ftpfilename = ftpfilename
		@historyfile = historyfile
		@historyDir = historyDir
		@logfile = logfile
		@logdirectory = logdirectory
		
		@msg = HAmsgProcessingService.new(@logfile,@logdirectory)
	end

	def sendFTPs
		begin
			ftpfileArray = Dir.glob(@localDir+@ftpfilename+"*").sort_by{|f| File.mtime(f) }

			ftp = Net::FTP.open(@ftpIP, @ftpUser, @ftpPassword)
				ftp.chdir(@remoteDir)
				ftpfileArray.each do |filename|
					@msg.processMsg("info", "log", "FTP processing file #{filename}")
					File.open(filename) { |file| 	
						ftp.putbinaryfile(file, remotefile = File.basename(filename)) 
					}
				end

			ftp.close
		rescue
			msgStr = "FTP failed on push. file =  #{@ftpfilename}.  Error #{$!}"
			@msg.processMsg("error", "severe", msgStr)
		end
	end	
	
	def getFTP
		begin
			ftp = Net::FTP.new(host = @ftpIP)
			ftp.login(user = @ftpUser, passwd = @ftpPassword)
			ftp.chdir(@remoteDir)
			ftp.getbinaryfile(@ftpfilename, remotefile = File.basename(@ftpfilename))
			ftp.close
		rescue 
			msgStr = "FTP failed on get. file =  #{@ftpfilename}.  Error #{$!}. Host = #{@ftpIP} User = #{@ftpUser} Password = #{@ftpPassword}"
			@msg.processMsg("error", "severe", msgStr)
		end
	end	
	
 end
