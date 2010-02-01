class MsBuildTask < Rake::TaskLib
	attr_accessor :src_dir, :verbosity, :working_dir

	def initialize(params={})
		#TODO: Support for arbitrary properties, not just configuration.  For example, TreatWarningsAsErrors, WarningLevel.
		@configuration = params[:configuration] || CONFIGURATION
		@src_dir = params[:src_dir] || SRC_DIR
		@verbosity = params[:verbosity] || MSBUILD_VERBOSITY || 'm'
		@working_dir = params[:working_dir] || '.'
		@deps = params[:deps] || [Bin_out]
		@buildable_projects = ['.csproj', '.vbproj', '.wdproj', '.wixproj']
		@properties = {:Configuration => @configuration, :TreatWarningsAsErrors => true, :WarningLevel => 4, :BuildInParallel => true}.merge(params[:properties] || {})

		yield self if block_given?
		define
	end

	def define
		# most project types put output into bin/{configuration}
		rule(/#{src_dir_regex}\/[\w\.]+\/bin\/#{@configuration}\/[\w\.]+\.(?:dll|exe)/) do |r|
			puts r.name
			build_lib(r)
		end

		# web application projects put output into /bin
		rule(/#{src_dir_regex}\/[\w\.]+\/bin\/[\w\.]+\.dll/) do |r|
			build_lib(r)
		end

		def build_lib(r)
			pn = Pathname.new(r.name)
			name = pn.basename.to_s.sub('.dll', '')
			project = FileList.new("#{@src_dir}/#{name}/#{name}.*proj").first
			mb = MsBuildCmd.new(project, @properties, ['Build'], @verbosity, @working_dir)
			mb.run
		end

		# web deployment projects put output into /{configuration}
		rule(/#{src_dir_regex}\/[\w\.]+\/#{@configuration}/) do |r|
			puts r.name
			build_wdp(r)
		end

		def build_wdp(r)
			pn = Pathname.new(r.name)
			name = Pathname.new(pn.dirname).basename
			project = FileList.new("#{@src_dir}/#{name}/#{name}.wdproj").first
			mb = MsBuildCmd.new(project, @properties, ['Build'], @verbosity, @working_dir)
			mb.run
		end

		desc "Compile the specified projects (give relative paths) (otherwise, all matching src/**/*.*proj)"
		task :compile, [:projects] do |t, args|
			project_list = FileList.new("#{src_dir}/*/*.*proj")
			args.with_defaults(:projects => project_list)
			args.projects.each do |p|
				pn = Pathname.new(p)
				# TODO: Figure out which type of project we are so we can invoke the correct rule, with the correct output extension
				if p.include?('csproj') || (p.include? 'vbproj')
					target = File.join(pn.dirname, 'bin', @configuration, pn.basename.sub(pn.extname, '.dll'))
				elsif p.include? 'wdproj'
					target = File.join(pn.dirname, @configuration)
				else
					raise(ArgumentError, "no support for project file of type #{pn.extname}")
				end

				Rake::FileTask[target].invoke if @buildable_projects.include?(pn.extname)
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
