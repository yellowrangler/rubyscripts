require 'rubygems'

class rsFiles
	
	def initialize()
	    @fromFile = ""
	    @toFile = ""
	    @delFile = ""
	end

    def cFile
		input = File.open(@fromFile)  
		data_to_copy = input.read()  
		output = File.open(@toFile , 'w')
		output.write(data_to_copy)  
	end
	
	
	def dFile
		File.delete(@delFile)
	end

	def renameFile(fromFile, toFile)
	    @fromFile = fromFile 
	    @toFile = toFile
	    begin
		cFile
        rescue
        puts sprintf("Error creating file. From file : %s  To File : %s", @fromFile, @toFile)
        abort
        end
		@delFile = @fromFile
		
		dFile
	end
	
end
