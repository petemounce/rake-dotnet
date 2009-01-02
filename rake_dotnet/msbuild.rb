class MSBuild
	attr_accessor :version
	attr_accessor :project
	attr_accessor :properties
	attr_accessor :targets
	attr_accessor :verbosity
	
	def initialize(opts)
		@project = opts.fetch(:project, 'default.proj')
		@properties = opts.fetch(:properties, {})
		@targets = opts.fetch(:targets, 'Rebuild')
		@verbosity = opts.fetch(:verbosity, 'n')
	end
	
	def run
		msbuildFile = File.join(File.join(ENV['windir'].dup, 'Microsoft.NET', 'Framework', 'v3.5'), 'msbuild.exe')
		p = []
		@properties.each {|key, value| p.push("#{key}=#{value}") }
		cmd = "\"#{msbuildFile}\" \"#{@project}\" /maxcpucount /v:#{@verbosity} /property:BuildInParallel=true /p:#{p.join(";")} /t:#{@targets}"
		sh cmd
	end
end
