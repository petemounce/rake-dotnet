class MsBuild
	attr_accessor :project, :properties, :targets, :verbosity
	
	def initialize(project='default.proj', properties={}, targets=[], verbosity='n')
		@project = project
		@properties = properties
		@targets = targets
		@verbosity = verbosity
		@exe = '"' + File.join(ENV['windir'].dup, 'Microsoft.NET', 'Framework', 'v3.5', 'msbuild.exe') + '"'
	end
	
	def run
		
		cmd = "#{@exe} #{project} /maxcpucount /v:#{@verbosity} /property:BuildInParallel=true /p:#{properties} /t:#{targets}"
		sh cmd
	end
	
	def project
		"\"#{@project}\""
	end
	
	def targets
		@targets.join(';')
	end
	
	def properties
		p = []
		@properties.each {|key, value| p.push("#{key}=#{value}") }
		p.join(';')
	end
end
