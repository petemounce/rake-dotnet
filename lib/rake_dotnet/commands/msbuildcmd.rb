class MsBuildCmd
	attr_accessor :project, :properties, :targets, :verbosity

	def initialize(project='default.proj', properties={}, targets=[], verbosity='n', working_dir=nil)
		@project = project
		@properties = properties
		@targets = targets
		@verbosity = verbosity
		@working_dir = working_dir
		@exe = '"' + File.join(ENV['windir'].dup, 'Microsoft.NET', 'Framework', 'v3.5', 'msbuild.exe') + '"'
	end

	def cmd
		"#{@exe} #{project} /maxcpucount /v:#{@verbosity} /p:#{properties} /t:#{targets}"
	end

	def run
		if @working_dir
			chdir(@working_dir) do
				puts cmd if VERBOSE
				sh cmd
			end
		end
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
