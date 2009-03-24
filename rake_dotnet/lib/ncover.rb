module Rake
	class NCoverTask < TaskLib
		def initialize(params={})
		
			@product_name = params[:product_name] || PRODUCT_NAME
			@bin_dir = params[:bin_dir] || File.join(OUT_DIR, 'bin')
			@report_dir = params[:report_dir] || File.join(OUT_DIR, 'reports')
			@deps = params[:deps] || []
			tool_defaults = {:arch => 'x86'}
			@ncover_options = tool_defaults.merge(params[:ncover_options] || {})
			@ncover_reporting_options = tool_defaults.merge(params[:ncover_reporting_options] || {})

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
				nc = NCover.new(@report_dir, dll_to_execute, @ncover_options)
				nc.run
			end
			
			desc "Generate ncover coverage XML, one file per test-suite that exercises your product"
			task :ncover_profile,[:dlls_to_run] => [@report_dir] do |t, args|
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
						
			ncover_summary_report_html = File.join(@report_dir, 'merged.MethodSourceCodeClassMethod.coverage-report.html')
			file ncover_summary_report_html do
				# ncover lets us use *.coverage.xml to merge together files
				include = [File.join(@report_dir, '*.coverage.xml')]
				@ncover_reporting_options[:name] = 'merged'
				ncr = NCoverReporting.new(@report_dir, include, @ncover_reporting_options)
				ncr.run
			end
			
			desc "Generate ncover coverage summary HTML report, on all coverage files, merged together"
			task :ncover_summary => [:ncover_profile, ncover_summary_report_html]
			
			task :clean_coverage do
				rm_rf 'out/reports/*coverage-report*'
			end
			
			self
		end
		
		self
	end
end

class NCover
	def initialize(report_dir, dll_to_execute, params)
		params ||= {}
		arch = params[:arch] || 'x86'
		@exe = params[:ncover_exe] || File.join(TOOLS_DIR, 'ncover', arch, 'ncover.console.exe')
		@dll_to_execute = dll_to_execute
		ofname = File.split(dll_to_execute)[1].sub(/(\.dll)/, '') + '.coverage.xml'
		@output_file = File.join(report_dir, ofname)
		@exclude_assemblies_regex = params[:exclude_assemblies_regex] || '.*Tests.*'
		@build_id = params[:build_id] || RDNVERSION
	end
	
	def cmdToRun
		x = XUnit.new(@dll_to_execute, {})
		x.cmd
	end
	
	def bi
		"//bi #{@build_id.to_s}"
	end
	
	def eas
		"//eas #{@exclude_assemblies_regex}"
	end
	
	def cmd
		"\"#{@exe}\" #{cmdToRun} //x #{@output_file} #{eas} #{bi}"
	end
	
	def run
		sh cmd
	end
end

class NCoverReporting
	def initialize(report_dir, coverage_files, params)
		@report_dir = report_dir
		@coverage_files = coverage_files || []

		params ||= {}
		arch = params[:arch] || 'x86'
		@exe = params[:ncover_reporting_exe] || File.join(TOOLS_DIR, 'ncover', arch, 'ncover.reporting.exe')

		# required
		@name = params[:name] || 'CoverageReport'
		@report = params[:report] || 'MethodSourceCodeClassMethod'
		@format = params[:report_format] || 'html' # can be xml or html
		@output_path = File.join(@report_dir, @name + '.' + @report + '.' + @format)
		
		# optional
		@build_id = params[:build_id] || RDNVERSION
		@so = params[:sort] || 'CoveragePercentageAscending'
	end
	
	def coverage_files
		list = ''
		@coverage_files.each do |cf|
			list += "\"#{cf}\" "
		end
		list
	end
	
	def bi
		"//bi #{@build_id.to_s}"
	end
	
	def r
		"//r #{@report}"
	end
	
	def op
		"//op \"#{@output_path}\""
	end
	
	def so
		"//so #{@so}"
	end
		
	def cmd
		"\"#{@exe}\" #{coverage_files} #{bi} #{r} #{op} #{so}"
	end
	
	def run
		sh cmd
	end
end
