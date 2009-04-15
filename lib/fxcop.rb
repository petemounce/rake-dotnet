module Rake
	class FxCopTask < TaskLib
		attr_accessor :dll_list, :suites_dir
		
		def initialize(params={})
			@product_name = params[:product_name] || PRODUCT_NAME
			@report_dir = params[:report_dir] || File.join(OUT_DIR, 'reports')
			@name = params[:name] || File.join(@report_dir, @product_name + '.fxcop')
			@suites_dir = params[:suites_dir] || File.join(OUT_DIR, 'bin')
			@dll_list = FileList.new
			@deps = params[:deps] || []
			@fxcop_options = {:apply_out_xsl=>true, :out_xsl=>'CodeAnalysisReport.xsl'}.merge(params[:fxcop_options] || {})
			if @fxcop_options[:apply_out_xsl].nil? || @fxcop_options[:apply_out_xsl] == false
				@name += '.xml' 
			else
				@name += '.html'
			end
			@fxcop_options[:out_file] = @name if @fxcop_options[:out_file].nil?
			
			yield self if block_given?
			define
		end
		
		def define
			@deps.each do |d|
				task :fxcop => d
			end
			
			directory @report_dir

			file @name => [@report_dir] do |f|
				runner = FxCop.new(@dll_list, @fxcop_options)
				runner.run
			end
			
			task :fxcop,[:globs] do |t, args|
				args.with_defaults(:globs => "#{@suites_dir}/**/*#{@product_name}*.dll")
				@dll_list = FileList.new(args.globs)
				Rake::FileTask[@name].invoke
			end
			
			self
		end
		
		self
	end
end

class FxCop
	attr_accessor :dlls, :out_file, :out_xsl, :apply_out_xsl, :dependencies_path, :summary, :verbose, :echo_to_console, :xsl_echo_to_console, :ignore_autogen, :culture

	def initialize(dlls, params={})
		@dlls = dlls

		@exe_dir = params[:fxcop_exe_dir] || File.join(TOOLS_DIR, 'fxcop')
		@exe = params[:fxcop_exe] || File.join(@exe_dir, 'fxcopcmd.exe')

		@apply_out_xsl = params[:apply_out_xsl]
		@culture = params[:culture]
		@dependencies_path = params[:dependencies_path]
		@echo_to_console = params[:echo_to_console]
		@ignore_autogen = params[:ignore_autogen] || true
		@out_file = params[:out_file]
		@out_xsl = File.join(@exe_dir, 'Xml', params[:out_xsl]) unless params[:out_xsl].nil?
		@summary = params[:summary]
		@verbose = params[:verbose]
		@xsl_echo_to_console = params[:xsl_echo_to_console]
		
		yield self if block_given?
	end
	
	def console
		'/console' if @echo_to_console || @out_file.nil?
	end

	def files_to_analyse
		list = ''
		@dlls.each do |dll|
			list += "/file:\"#{dll}\" "
		end
		list = list.chop
	end

	def out_file
		"/out:\"#{@out_file}\"" if @out_file
	end

	def out_xsl
		"/outxsl:\"#{@out_xsl}\"" if @out_xsl
	end

	def apply_out_xsl
		"/applyoutxsl" if @apply_out_xsl
	end
	
	def cmd
		"\"#{@exe}\" #{files_to_analyse} #{console} #{out_file} #{out_xsl} #{apply_out_xsl}"
	end

	def run
		sh cmd
	end
end
