module Rake
	class NCoverTask < TaskLib
		def initialize(params={})
		
			@product_name = params[:product_name] || PRODUCT_NAME
			@bin_dir = params[:bin_dir] || File.join(OUT_DIR, 'bin')
			@report_dir = params[:report_dir] || File.join(OUT_DIR, 'reports')
			@deps = params[:deps] || []

			yield self if block_given?
			define
		end
		
		def define
			@deps.each do |d|
				task :fxcop => d
			end
			
			puts @report_dir
			directory @report_dir
			
			reports_dir_regex = regexify(@report_dir)
			rule(/#{reports_dir_regex}\/.*\.coverage\.xml/) do |r|
				dll_to_execute = r.name.sub(/#{@report_dir}\/(.*)\.coverage\.xml/, "#{@bin_dir}/\\1.dll")
				@dlls_to_profile.delete_if do |e|
					e.match(/Tests/)
				end
				nc = NCover.new(@report_dir, dll_to_execute, @dlls_to_profile, {})
				nc.run
			end
			
			desc "Generate ncover coverage XML, one file per test-suite that exercises your product"
			task :ncover_profile,[:dlls_to_run] do |t, args|
				@dlls_to_profile = FileList.new
				@dlls_to_profile.include("#{@bin_dir}/**/*#{@product_name}*.dll")
				@dlls_to_profile.include("#{@bin_dir}/**/*#{@product_name}*.exe")

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
			
			self
		end
		
		self
	end
end

class NCover
	def initialize(report_path, dll_to_execute, dlls_to_profile, params)
		params ||= {}
		arch = params[:arch] || 'x86'
		@exe = params[:ncover_exe] || File.join(TOOLS_DIR, 'ncover', arch, 'ncover.console.exe')
		@dll_to_execute = dll_to_execute
		@dlls_to_profile = ''
		dlls_to_profile.each do |dll|
			f = File.split(dll)[1]
			f.slice(/(.*)\.dll/)
			@dlls_to_profile += f + ';'
		end
		@dlls_to_profile = @dlls_to_profile.chop
		ofname = File.split(dll_to_execute)[1].sub(/(\.dll)/, '') + '.coverage.xml'
		@output_file = File.join(report_path, ofname)
	end
	
	def cmdToRun
		x = XUnit.new(@dll_to_execute, {})
		x.cmd
	end
	
	def cmd
		"\"#{@exe}\" #{cmdToRun} //a #{@dlls_to_profile} //x #{@output_file}"
	end
	
	def run
		sh cmd
	end
end

class NCoverExplorer
	attr_accessor :exe, :coverage_files, :html, :report, :min, :fail_min, :sort, :filter, :save
	def initialize(coverage_files)
		@exe = File.join(TOOLS_DIR, 'ncover', 'x86', 'ncoverexplorer.console.exe')
		@coverage_files = coverage_files
	end
	
	def coverage_files
		@coverage_files.join(' ')
	end
	def html
		"/html:#{@html}" unless @html.nil?
	end
	def report
		"/report:#{@report}" if @report
	end
	def min
		"/minCoverage:#{@min}" if @min
	end
	def fail_min
		"/f" if @fail_min
	end
	def sort
		"/sort:#{@sort}" if @sort
	end
	def filter
		"/filter:#{@filter}" if @filter
	end
	def save
		"/save:#{@save}" if @save
	end
		
	def cmd
		"\"#{@exe}\" #{coverage_files} #{html} #{report} #{min} #{fail_min} #{sort} #{filter} #{save}"
	end
	
	def run
		sh cmd
	end
end
