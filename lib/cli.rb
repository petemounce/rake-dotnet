class Cli
	attr_accessor :bin, :search_paths

	def initialize(params={})
		@bin = params[:exe] || nil
		@exe_name = params[:exe_name] #required for inferring path

		# guessable / defaultable
		@search_paths = params[:search_paths] || []
		@search_paths << nil # use the one that will be found in %PATH%
	end

	def exe
		return @bin unless @bin.nil?

		@bin = "#{search_for_exe}"

		return @bin
	end

	def cmd
		return "\"#{exe}\""
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
		raise(ArgumentError, "No executable found in search-paths or system-PATH", caller)
	end
end
