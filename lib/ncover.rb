module Rake
	class NCoverTask < TaskLib
		attr_accessor :profile_options, :reporting_options
		def initialize(params={})
			@product_name = params[:product_name] || PRODUCT_NAME
			@bin_dir = params[:bin_dir] || File.join(OUT_DIR, 'bin')
			@report_dir = params[:report_dir] || File.join(OUT_DIR, 'reports', 'ncover')
			@deps = params[:deps] || []
			tool_defaults = {:arch => ENV['PROCESSOR_ARCHITECTURE']}
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
				nc = NCover.new(@report_dir, dll_to_execute, @profile_options)
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
						
			desc "Generate ncover coverage report(s), on all coverage files, merged together"
			task :ncover_reports => [:ncover_profile] do
				# ncover lets us use *.coverage.xml to merge together files
				include = [File.join(@report_dir, '*.coverage.xml')]
				@reporting_options[:name] = 'merged'
				ncr = NCoverReporting.new(@report_dir, include, @reporting_options)
				ncr.run
			end
			
			task :clobber_ncover do
				rm_rf @report_dir
			end
			
			self
		end
		
		self
	end
end

class NCover
	def initialize(report_dir, dll_to_execute, params)
		params ||= {}
		arch = params[:arch] || ENV['PROCESSOR_ARCHITECTURE']
		@exe = params[:ncover_exe] || File.join(TOOLS_DIR, 'ncover', arch, 'ncover.console.exe')
		@dll_to_execute = dll_to_execute
		ofname = File.split(dll_to_execute)[1].sub(/(\.dll)/, '') + '.coverage.xml'
		@output_file = File.join(report_dir, ofname)
		@exclude_assemblies_regex = params[:exclude_assemblies_regex] || ['.*Tests.*']
		@exclude_assemblies_regex.push('ISymWrapper')
		@build_id = params[:build_id] || RDNVERSION
		@working_dir = params[:working_dir] || Pathname.new(@dll_to_execute).dirname
	end
	
	def cmdToRun
		x = XUnit.new(@dll_to_execute, '', nil, {})
		x.cmd
	end
	
	def bi
		"//bi #{@build_id.to_s}"
	end
	
	def working_dir
		"//w #{@working_dir}"
	end
	
	def exclude_assemblies
		if @exclude_assemblies_regex.instance_of?(Array)
			return '//eas ' + @exclude_assemblies_regex.join(';')
		end
		return '//eas ' + @exclude_assemblies_regex if @exclude_assemblies_regex.instance_of?(String)
	end

	def cmd
		"\"#{@exe}\" #{cmdToRun} //x #{@output_file} #{exclude_assemblies} #{bi} #{working_dir}"
	end
	
	def run
		puts cmd if VERBOSE
		sh cmd
	end
end

class NCoverReporting
	def initialize(report_dir, coverage_files, params)
		@report_dir = report_dir
		@coverage_files = coverage_files || []

		params ||= {}
		arch = params[:arch] || ENV['PROCESSOR_ARCHITECTURE']
		@exe = params[:ncover_reporting_exe] || File.join(TOOLS_DIR, 'ncover', arch, 'ncover.reporting.exe')

		# required
		@reports = params[:reports] || ['Summary', 'UncoveredCodeSections', 'FullCoverageReport']
		@output_path = File.join(@report_dir)
		
		# optional
		@build_id = params[:build_id] || RDNVERSION
		@sort_order = params[:sort] || 'CoveragePercentageAscending'
		@project_name = params[:project_name] || PRODUCT_NAME
	end
	
	def coverage_files
		list = ''
		@coverage_files.each do |cf|
			list += "\"#{cf}\" "
		end
		list
	end
	
	def build_id
		"//bi #{@build_id.to_s}"
	end
	
	def output_reports
		cmd = ''
		@reports.each do |r|
			cmd += "//or #{r} "
		end
		return cmd
	end
	
	def output_path
		"//op \"#{@output_path}\""
	end
	
	def sort_order
		"//so #{@sort_order}"
	end
	
	def project_name
		"//p #{@project_name}" unless @project_name.nil?
	end
		
	def cmd
		"\"#{@exe}\" #{coverage_files} #{build_id} #{output_reports} #{output_path} #{sort_order} #{project_name}"
	end
	
	def run
		sh cmd
	end
end
