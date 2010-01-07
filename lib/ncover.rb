class NCoverTask < Rake::TaskLib
	attr_accessor :profile_options, :reporting_options

	def initialize(params={})
		@product_name = params[:product_name] || PRODUCT_NAME
		@bin_dir = params[:bin_dir] || File.join(OUT_DIR, 'bin')
		@report_dir = params[:report_dir] || File.join(OUT_DIR, 'reports', 'ncover')
		@deps = params[:deps] || []
		tool_defaults = {:arch => ENV['PROCESSOR_ARCHITECTURE']}
		@allow_iis_profiling = params[:allow_iis_profiling] || false
		@profile_options = tool_defaults.merge(params[:profile_options] || {})
		@reporting_options = tool_defaults.merge(params[:reporting_options] || {})

		yield self if block_given?
		define
	end

	def define
		@deps.each do |d|
			task :ncover_profile => d
		end

		directory @report_dir

		reports_dir_regex = RakeDotNet::regexify(@report_dir)
		rule(/#{reports_dir_regex}\/.*\.coverage\.xml/) do |r|
			dll_to_execute = r.name.sub(/#{@report_dir}\/(.*)\.coverage\.xml/, "#{@bin_dir}/\\1.dll")
			if (shouldProfileIis(dll_to_execute))
				@profile_options[:profile_iis] = @allow_iis_profiling
			end
			nc = NCoverConsoleCmd.new(@report_dir, dll_to_execute, @profile_options)
			nc.run
		end

		def shouldProfileIis(dll)
			dll = dll.downcase
			return true if dll.include? 'functional'
			return true if dll.include? 'browser'
			return true if dll.include? 'selenium'
			return true if dll.include? 'watin'
			return false
		end

		desc "Generate ncover coverage XML, one file per test-suite that exercises your product"
		task :ncover_profile, [:dlls_to_run] => [@report_dir] do |t, args|
			dlls_to_run_list = FileList.new
			dlls_to_run_list.include("#{@bin_dir}/**/*#{@product_name}*Tests*.dll")
			dlls_to_run_list.include("#{@bin_dir}/**/*#{@product_name}*Tests*.exe")
			args.with_defaults(:dlls_to_run => dlls_to_run_list)
			args.dlls_to_run.each do |d|
				dll_to_run = Pathname.new(d)
				cf_name = dll_to_run.basename.sub(dll_to_run.extname, '.coverage.xml')
				coverage_file = File.join(@report_dir, cf_name)
				Rake::FileTask[coverage_file].invoke
			end
		end

		rule(/#{reports_dir_regex}\/.*\//) do |report_set|
			set_name = report_set.name.match(/#{reports_dir_regex}\/(.*)\//)[1]
			profile_xml = File.join(@report_dir, "#{set_name}.coverage.xml")
			mkdir_p report_set.name
			@reporting_options[:project_name] = set_name
			ncr = NCoverReportingCmd.new(report_set.name, profile_xml, @reporting_options)
			ncr.run
		end

		desc "Generate ncover coverage report(s), on all coverage files"
		task :ncover_reports => [:ncover_profile] do
			report_sets = FileList.new("#{@report_dir}/**/*.coverage.xml")
			report_sets.each do |set|
				cov_report = set.sub('.coverage.xml', '/')
				Rake::FileTask[cov_report].invoke
			end
		end

		task :clobber_ncover do
			rm_rf @report_dir
		end

		self
	end
end

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

		@profile_iis = params[:profile_iis] || false
		@working_dir = params[:working_dir] || Pathname.new(@dll_to_execute).dirname

		@is_complete_version = `#{@exe}`.include?('NCover Complete v')
	end

	def cmdToRun
		x = XUnitConsoleCmd.new(@dll_to_execute, '', nil, {})
		x.cmd
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

	def cmd
		"\"#{@exe}\" #{cmdToRun} //x #{@output_file} #{exclude_assemblies} #{bi} #{working_dir} #{iis}"
	end

	def run
		puts cmd if VERBOSE
		sh cmd
		puts "##teamcity[importData type='dotNetCoverage' tool='ncover3' path='#{File.expand_path(@output_file)}']" if ENV['BUILD_NUMBER']
	end
end

class NCoverReportingCmd
	def initialize(report_dir, coverage_files, params)
		@report_dir = report_dir
		@coverage_files = coverage_files || []

		params ||= {}
		arch = params[:arch] || ENV['PROCESSOR_ARCHITECTURE']
		@exe = params[:ncover_reporting_exe] || File.join(TOOLS_DIR, 'ncover', arch, 'ncover.reporting.exe')

		@is_complete_version = `#{@exe}`.include?('NCover Reporting Complete v')
		# required
		@reports = params[:reports] || ['Summary', 'UncoveredCodeSections', 'FullCoverageReport']
		@output_path = File.join(@report_dir)

		# optional
		@sort_order = params[:sort] || 'CoveragePercentageAscending'
		@project_name = params[:project_name] || PRODUCT_NAME
	end

	def coverage_files
		list = ''
		@coverage_files.each do |cf|
			list += "\"#{cf}\" "
		end
		return list
	end

	def build_id
		return "//bi #{Versioner.new.get.to_s}"
	end

	def output_reports
		cmd = ''
		if @is_complete_version
			@reports.each do |r|
				cmd += "//or #{r} "
			end
		else
			classic_version_reports_allowed = ['Summary', 'SymbolModule', 'SymbolModuleNamespace', 'SymbolModuleNamespaceClass', 'SymbolModuleNamespaceClassMethod']
			@reports.each do |r|
				cmd += "//or #{r} " if classic_version_reports_allowed.include?(r)
			end
		end
		return cmd
	end

	def output_path
		return "//op \"#{@output_path}\""
	end

	def sort_order
		return "//so #{@sort_order}"
	end

	def project_name
		return "//p #{@project_name}" unless @project_name.nil?
	end

	def cmd
		return "\"#{@exe}\" #{coverage_files} #{build_id} #{output_reports} #{output_path} #{sort_order} #{project_name}"
	end

	def run
		puts cmd if VERBOSE
		sh cmd
	end
end
