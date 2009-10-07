class Svn < Cli
	def initialize(params={})
		sps = params[:search_paths] || []
		sps << File.join(TOOLS_DIR, 'svn', 'bin')
		sps << File.join(ENV['PROGRAMFILES'], 'subversion', 'bin')
		sps << File.join(ENV['PROGRAMFILES'], 'svn', 'bin')
		super(params.merge(:search_paths=>sps))
	end

	def cmd
		return super
	end
end

class SvnExport < Svn
	def initialize(params={})
		super(params)
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
		puts super
		#s = super
		#return "#{s} export #{src} #{dest}"
	end

	def run
		puts cmd if VERBOSE==true
		sh cmd
	end
end

class SvnInfo < Svn
	attr_accessor :svn

	def initialize(opts)
		super(opts)
		@path = opts[:path] || '.'
		yield self if block_given?
	end

	def cmd
		"#{exe} info #{path}"
	end

	def revision
		puts cmd if VERBOSE
		out = `#{cmd}`
		out.match(/Revision: (\d+)/)[1]
	end

	def path
		"\"#{@path}\""
	end
end
