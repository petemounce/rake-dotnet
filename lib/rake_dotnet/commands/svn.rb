class SvnCmd < Cli
	def initialize(params={})
		sps = params[:search_paths] || []
		sps << File.join(TOOLS_DIR, 'svn', 'bin')
		sps << File.join(ENV['PROGRAMFILES'], 'subversion', 'bin')
		sps << File.join(ENV['PROGRAMFILES'], 'svn', 'bin')
		super(params.merge({:exe_name=>'svn.exe', :search_paths=>sps}))
	end

	def cmd
		return super
	end
end

class SvnExport < SvnCmd
	def initialize(params={})
		super
		raise(ArgumentError, "src parameter was missing", caller) if params[:src].nil?
		raise(ArgumentError, "dest parameter was missing", caller) if params[:dest].nil?
		@src = params[:src]
		@dest = params[:dest]
	end

	def src
		return "\"#{File.expand_path(@src)}\""
	end

	def dest
		return "\"#{File.expand_path(@dest)}\""
	end

	def cmd
		return "#{super} export #{src} #{dest}"
	end

	def run
		puts cmd if verbose
		sh cmd
	end
end

class SvnInfo < SvnCmd
	def initialize(params={})
		super
		@path = params[:path] || '.'
	end

	def cmd
		"#{super} info #{path}"
	end

	def revision
		puts cmd if verbose
		out = `#{cmd}`
		out.match(/Revision: (\d+)/)[1]
	end

	def path
		"\"#{@path}\""
	end
end
