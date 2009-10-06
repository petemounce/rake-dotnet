class Cli
	attr_accessor :exe
	
	def initialize(params={})
		@exe_name = params[:exe_name] #required for inferring path
		
		# guessable / defaultable
		@search_paths = params[:search_paths] || []
		@search_paths.push(nil) # use the one that will be found in %PATH%
	end
	
	def exe
		return @exe unless @exe.nil?
		
		@exe = "\"#{search_for_exe}\""
		
		return @exe
	end
	
	def search_for_exe
		@search_paths.each do |sp|
			puts 'sp: ' +sp.to_s
			if sp.nil?
				return @exe_name #because we add bare exe as last element in array
			else
				path = File.join(sp, @exe_name).to_s
				puts 'path: ' + path
				exists = File.exist? path
				puts "checking #{path}, got #{exists.to_s}"
				if exists
					puts 'returning '+ File.expand_path(path)
					return File.expand_path(path)
				end
			end
		end
	end
end
