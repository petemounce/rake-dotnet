class NCoverConsoleCmd
	def initialize(report_dir, dll_to_execute, params)
		params ||= {}
		arch = params[:arch] || ENV['PROCESSOR_ARCHITECTURE']
		@exe = params[:ncover_exe] || File.join(TOOLS_DIR, 'ncover', arch, 'ncover.console.exe')
		@dll_to_execute = dll_to_execute
		ofname = File.split(dll_to_execute)[1].sub(/(\.dll)/, '') + '.coverage.xml'
		@output_file = File.join(report_dir, ofname)

		@exclude_assemblies_regex = params[:exclude_assemblies_regex] || ['.*Tests.*']
		@exclude_assemblies_regex.push('ISymWrapper')
		@exclude_files_regex = params[:exclude_files_regex] || ['.*\.[Dd]esigner.cs']
		@cmd_to_run = params[:cmd_to_run]
		raise(ArgumentError, 'must supply a command-line string to run (eg, `NunitCmd.new(options).cmd`, `XUnitConsoleCmd.new(options).cmd`)', caller) if @cmd_to_run.nil?

		@profile_iis = params[:profile_iis] || false
		@working_dir = params[:working_dir] || Pathname.new(@dll_to_execute).dirname

		@is_complete_version = `#{@exe}`.include?('NCover Complete')
	end

	def bi
		return "//bi #{Versioner.new.get.to_s}"
	end

	def working_dir
		return "//w #{@working_dir}"
	end

	def iis
		return '' unless @is_complete_version
		return "//iis" if @profile_iis
	end

	def exclude_assemblies
		return '' unless @is_complete_version
		if @exclude_assemblies_regex.instance_of?(Array) && @exclude_assemblies_regex.length > 0
			return '//eas ' + @exclude_assemblies_regex.join(';')
		end
		return '//eas ' + @exclude_assemblies_regex if @exclude_assemblies_regex.instance_of?(String)
		return ''
	end

	def exclude_files
		return '' unless @is_complete_version
		if @exclude_files_regex.instance_of?(Array) && @exclude_files_regex.length > 0
			return '//ef ' + @exclude_files_regex.join(';')
		end
		return '//ef ' + @exclude_files_regex if @exclude_files_regex.instance_of?(String)
		return ''
	end

	def cmd
		"\"#{@exe}\" #{@cmd_to_run} //x #{@output_file} #{exclude_assemblies} #{exclude_files} #{bi} #{working_dir} #{iis}"
	end

	def run
		puts cmd if VERBOSE
		sh cmd
		puts "##teamcity[importData type='dotNetCoverage' tool='ncover3' path='#{File.expand_path(@output_file)}']" if ENV['BUILD_NUMBER']
	end
end
