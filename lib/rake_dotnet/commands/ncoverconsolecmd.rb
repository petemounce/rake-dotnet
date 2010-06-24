class NCoverConsoleCmd
	attr_accessor :exclude_assemblies

	def initialize(report_dir, dll_to_execute, params)
		params ||= {}
		@arch = params[:arch] || ENV['PROCESSOR_ARCHITECTURE']
		@exe = params[:ncover_exe] || File.join(TOOLS_DIR, 'ncover', @arch, 'ncover.console.exe')
		@dll_to_execute = dll_to_execute
		ofname = File.split(dll_to_execute)[1].sub(/(\.dll)/, '') + '.coverage.xml'
		@output_file = File.join(report_dir, ofname)
		@trend_file = params[:trend_file] || File.join(report_dir, ofname.sub('.coverage.xml', '.coverage.trend.xml'))
		@exclude_assemblies = params[:exclude_assemblies_regex] || ['.*Tests.*']
		@exclude_assemblies.push('ISymWrapper')
		@exclude_files_regex = params[:exclude_files_regex] || ['.*\.[Dd]esigner.cs']
		@cmd_to_run = params[:cmd_to_run]
		raise(ArgumentError, 'must supply a command-line string to run (eg, `NunitCmd.new(options).cmd`, `XUnitCmd.new(options).cmd`)', caller) if @cmd_to_run.nil?
		@profile_iis = params[:profile_iis] || false
		@service_timeout = params[:service_timeout] || nil
		@working_dir = params[:working_dir] || Pathname.new(@dll_to_execute).dirname.to_s

		@is_complete_version = `#{File.expand_path(@exe)}`.include?('NCover Complete')
	end

	def bi
		return "//bi #{Versioner.new.get.to_s}"
	end

	def working_dir
		return "//w \"#{@working_dir.gsub('/', '\\')}\""
	end

	def iis
		return '' unless @is_complete_version
		return "//iis" if @profile_iis
	end

	def st
		return "//st #{@service_timeout}" unless @service_timeout.nil?
		return ''
	end

	def exclude_assemblies_param
		return '' unless @is_complete_version
		if @exclude_assemblies.instance_of?(Array) && @exclude_assemblies.length > 0
			return '//eas ' + @exclude_assemblies.join(';')
		end
		return '//eas ' + @exclude_assemblies if @exclude_assemblie.instance_of?(String)
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

	def trend_file
		return '' unless @is_complete_version
		return '' if @trend_file.nil? || @trend_file == false
		t = File.expand_path(@trend_file).gsub('/', '\\')
		return "//at \"#{t}\""
	end

	def reg
		return '//reg' if @arch == 'x86'
		return ''
	end

	def cmd
		"\"#{@exe}\" #{@cmd_to_run} //x #{@output_file} #{trend_file} #{exclude_assemblies_param} #{exclude_files} #{bi} #{working_dir} #{iis} #{st} #{reg}"
	end

	def run
		puts cmd if verbose
		status, stdout, stderr = systemu cmd
		puts "##teamcity[importData type='dotNetCoverage' tool='ncover3' path='#{File.expand_path(@output_file)}']" if ENV['BUILD_NUMBER']
		return {:status=>status, :stdout=>stdout, :stderr=>stderr}
	end
end
