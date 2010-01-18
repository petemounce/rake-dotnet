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

		reports_dir_regex = regexify(@report_dir)
		rule(/#{reports_dir_regex}\/.*\.coverage\.xml/) do |r|
			dll_to_execute = r.name.sub(/#{@report_dir}\/(.*)\.coverage\.xml/, "#{@bin_dir}/\\1.dll")
			if (should_profile_iis(dll_to_execute))
				@profile_options[:profile_iis] = @allow_iis_profiling
			end
			@profile_options[:cmd_to_run] = case @profile_options[:test_framework]
				when :xunit then XUnitCmd.new(dll_to_execute, '', nil, {}).cmd
				when :nunit then NUnitCmd.new(:input_files=>dll_to_execute, :options=>{:xml=>false}).cmd
				else raise(ArgumentError, ':test_framework must be one of [:nunit,:xunit]', caller)
			end
			nc = NCoverConsoleCmd.new(@report_dir, dll_to_execute, @profile_options)
			nc.run
		end

		def should_profile_iis (dll)
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

		task :ncover => [:ncover_profile, :ncover_reports]

		desc 'Generate coverage data and run ncover reports based on it'
		task :coverage => :ncover

		task :clobber_ncover do
			rm_rf @report_dir
		end

		desc 'Clobber coverage reports'
		task :clobber_coverage => :clobber_ncover
	end
end


