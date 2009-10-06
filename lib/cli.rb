class Cli
	attr_accessor :exe, :search_paths
	
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
			if sp.nil?
				return @exe_name #because we add bare exe as last element in array
			else
				path = File.join(sp, @exe_name)
				return File.expand_path(path) if File.exist? path
			end
		end
	end
end
