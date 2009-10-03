class Cli
	def initialize(params={})
		@exe_name = params[:exe_name] #required!
		
		# guessable / defaultable
		@search_paths = params[:search_paths] || []
		@search_paths.push(@exe_name)
	end
	
	def exe
		@search_paths.each do |sp|
			path = File.join(sp, @exe_name)
			pn = Pathname.new(path)
			return "\"#{File.expand_path(pn).gsub('/','\\')}\"" if pn.exist?
		end
	end
end
