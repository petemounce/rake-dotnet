class NCoverTask < Rake::TaskLib
	include DependentTask
	attr_accessor :profile_options, :reporting_options, :runner_options, :merge_options
	attr_accessor :product_name, :bin_dir, :report_dir, :should_publish

	def initialize(params={})
		@product_name = params[:product_name] || PRODUCT_NAME
		@bin_dir = params[:bin_dir] || File.join(OUT_DIR, 'bin')
		@report_dir = params[:report_dir] || File.join(OUT_DIR, 'reports', 'ncover')
		tool_defaults = {:arch => ENV['PROCESSOR_ARCHITECTURE']}
		@allow_iis_profiling = params[:allow_iis_profiling] || false
		@profile_options = tool_defaults.merge(params[:profile_options] || {})
		@reporting_options = tool_defaults.merge(params[:reporting_options] || {})
		@merge_options = tool_defaults.merge(params[:merge_options] || {
				:reports=>[],
				:project_name=>"#{PRODUCT_NAME}.merged",
				:save_to=>File.join(@report_dir, "#{PRODUCT_NAME}.merged.coverage.xml")})
		@runner_options = params[:runner_options] || {:xml => false}
		@should_publish = ENV['BUILD_NUMBER'] || params[:should_publish] || false

		yield self if block_given?
		@main_task_name = :ncover
		params[:build_number] ||= ENV['BUILD_NUMBER']
		super(params)
		define
	end

	def define
		directory @report_dir

		reports_dir_regex = regexify(@report_dir)
		rule(/#{reports_dir_regex}\/.*\.coverage\.xml/) do |r|
			dll_to_execute = r.name.sub(/#{@report_dir}\/(.*)\.coverage\.xml/, "#{@bin_dir}/\\1.dll")
			if (should_profile_iis(dll_to_execute))
				@profile_options[:profile_iis] = @allow_iis_profiling
			end
			@profile_options[:cmd_to_run] = case @profile_options[:test_framework]
				when :xunit then
					XUnitCmd.new(dll_to_execute, '', nil, @runner_options).cmd
				when :nunit then
					NUnitCmd.new(:input_files=>dll_to_execute, :options => @runner_options).cmd
				else
					raise(ArgumentError, ':test_framework must be one of [:nunit,:xunit]', caller)
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

		desc "Merge coverage profile data into single file"
		task :ncover_merged => [@report_dir, :ncover_profile] do
			merged_coverage_xml = File.join(@report_dir, "#{PRODUCT_NAME}.merged.coverage.xml")
			rm merged_coverage_xml if File.exists? merged_coverage_xml
			ncr = NCoverReportingCmd.new(@report_dir, "#{@report_dir}/*.coverage.xml", @merge_options)
			ncr.run
		end

		task :ncover_publish do
			if @should_publish
				FileList.new("#{@report_dir}/*").each do |entry|
					e = Pathname.new(entry)
					if e.directory? && e.children.length > 0
						summary_html = e.children.select { |c| c.to_s.include? '/summary.html' }
						doc = REXML::Document.new(File.open(summary_html.first))
						spans = REXML::XPath.match(doc, "//div[@id='left']/p/span")
						key = to_attr(e.basename)
						publish_from_xpath("NCoverSymbol_#{key}", spans[0], /(\d+\.?\d*)%/)
						publish_from_xpath("NCoverBranch_#{key}", spans[1], /(\d+\.?\d*)%/)
						publish_from_xpath("NCoverMethod_#{key}", spans[2], /(\d+\.?\d*)%/)
						publish_from_xpath("NCoverCycCompAvg_#{key}", spans[3], /(\d+\.?\d*)/)
						publish_from_xpath("NCoverCycCompMax_#{key}", spans[4], /(\d+\.?\d*)/)
						if e.basename.to_s.include? '.merged'
							publish_from_xpath("NCoverSymbol_Merged", spans[0], /(\d+\.?\d*)%/)
							publish_from_xpath("NCoverBranch_Merged", spans[1], /(\d+\.?\d*)%/)
							publish_from_xpath("NCoverMethod_Merged", spans[2], /(\d+\.?\d*)%/)
							publish_from_xpath("NCoverCycCompAvg_Merged", spans[3], /(\d+\.?\d*)/)
							publish_from_xpath("NCoverCycCompMax_Merged", spans[4], /(\d+\.?\d*)/)
						end
					end
				end
			end
		end

		def publish_from_xpath(key, span, regex)
			if span && span.text
				value_matches = span.text.match(regex)
				puts "##teamcity[buildStatisticValue key='#{key}' value='#{value_matches[1]}']" unless value_matches.nil?
			end
		end

		task @main_task_name => [:ncover_profile, :ncover_merged, :ncover_reports, :ncover_publish]

		desc 'Generate coverage data and run ncover reports based on it'
		task :coverage => @main_task_name

		task :clobber_ncover do
			rm_rf @report_dir
		end

		desc 'Clobber coverage reports'
		task :clobber_coverage => :clobber_ncover
	end
end


