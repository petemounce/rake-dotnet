class Svn
	attr_accessor :svn

	def initialize
		@svn = File.join('..', '_library', 'svn', 'bin', 'svn.exe')
		yield self if block_given?
	end
	
	def exe
		"\"#{@svn}\""
	end
end

class SvnExport < Svn
	def initialize(src, dest)
		@svn = File.join('..', '_library', 'svn', 'bin', 'svn.exe')
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
	
	def initialize(path = '.')
		super()
		@path = path
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