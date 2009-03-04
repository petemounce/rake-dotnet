class Svn
	attr_accessor :svn

	def initialize(opts={})
		@svn = File.join(TOOLS_DIR, 'svn', 'bin', 'svn.exe')
		yield self if block_given?
	end
	
	def exe
		"\"#{@svn}\""
	end
end

class SvnExport < Svn
	def initialize(src, dest, opts={})
		super(opts)
		@src = src
		@dest = dest
	end
	
	def export
		sh "#{exe} export #{src} #{dest}"
	end
	
	def src
		"\"#{@src}\""
	end
	def dest
		"\"#{@dest}\""
	end	
end

class SvnInfo < Svn
	attr_accessor :svn
	
	def initialize(opts)
		super(opts)
		@path = opts[:path] || '.'
		yield self if block_given?
	end

	def revision
		cmd = "#{@svn} info #{path}"
		out = `#{cmd}`
		out.match(/Revision: (\d+)/)[1]
	end
	
	def path
		"\"#{@path}\""
	end
end