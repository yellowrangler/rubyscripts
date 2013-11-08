#!/usr/bin/env ruby
require './HAmsgProcessingService'
require './HAftpService'
require './HAbackupFilesService'


ftpIP = "marthasvineyard"
localDir = "data/"
ftpUser = "fileserver"
ftpPassword = "fileserver"
remoteDir = "incoming/"
ftpfilename = "HA_"
historyfile = "ftpLogger"
historyDir = "/home/tarryc/Development/rubyScripts/log/"
logfile = "ftpLogger"
logdirectory = "/home/tarryc/Development/rubyScripts/log/"
backupDirectory = "/home/tarryc/Development/rubyScripts/backup/"

# Send faxes to catcher server directory
msg = HAmsgProcessingService.new(logfile,logdirectory)
msg.processMsg("info", "log", "FTP Manager start")

#ftp fax items
ftp = HAftpService.new(ftpIP,localDir,ftpUser,ftpPassword,remoteDir,ftpfilename,historyfile,historyDir,logfile,logdirectory)
ftp.sendFTPs

#move copied files to backup directory
bk = HAbackupFilesService.new(logfile,logdirectory,ftpfilename,localDir,backupDirectory)
bk.backupFiles

msg.processMsg("info", "log", "FTP Manager end\n")

