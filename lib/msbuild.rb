module Rake
	class MsBuildTask < TaskLib
		attr_accessor :src_dir, :verbosity, :working_dir
	
		def initialize(params={})
			#TODO: Support for arbitrary properties, not just configuration.  For example, TreatWarningsAsErrors, WarningLevel.
			@configuration = params[:configuration] || CONFIGURATION
			@src_dir = params[:src_dir] || SRC_DIR
			@verbosity = params[:verbosity] || MSBUILD_VERBOSITY || 'm'
			@working_dir = params[:working_dir] || '.'
			@deps = params[:deps] || []
			
			yield self if block_given?
			define
		end
		
		def define
			# most project types put output into bin/{configuration}
			rule(/#{src_dir_regex}\/[\w\.]+\/bin\/#{@configuration}\/[\w\.]+\.(?:dll|exe)/) do |r|
				pn = Pathname.new(r.name)
				name = pn.basename.to_s.sub('.dll', '')
				project = File.join(@src_dir, name, name + '.csproj')
				mb = MsBuild.new(project, {:Configuration => @configuration}, ['Build'], verbosity, @working_dir)
				mb.run
			end
			
			# web application projects put output into /bin
			rule(/#{src_dir_regex}\/[\w\.]+\/bin\/[\w\.]+\.dll/) do |r|
				pn = Pathname.new(r.name)
				name = pn.basename.to_s.sub('.dll', '')
				project = File.join(@src_dir, name, name + '.csproj')
				mb = MsBuild.new(project, {:Configuration => @configuration}, ['Build'], verbosity, @working_dir)
				mb.run
			end

			desc "Compile the specified projects (give relative paths) (otherwise, all matching src/**/*.*proj)"
			task :compile,[:projects] do |t, args|
				project_list = FileList.new("#{src_dir}/**/*.*proj")
				args.with_defaults(:projects => project_list)
				args.projects.each do |p|
					pn = Pathname.new(p)
					# TODO: Figure out which type of project we are so we can invoke the correct rule, with the correct output extension
					dll = File.join(pn.dirname, 'bin', @configuration, pn.basename.sub(pn.extname, '.dll'))
					Rake::FileTask[dll].invoke
				end
			end

			@deps.each do |d|
				task :compile => d
			end
			
			self
		end
		
		def src_dir_regex
			regexify(@src_dir)
		end
		
		def figure_out_project_type(project_pathname)
			# TODO.
		end
	end
end

class MsBuild
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
		"#{@exe} #{project} /maxcpucount /v:#{@verbosity} /property:BuildInParallel=true /p:#{properties} /t:#{targets}"
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
