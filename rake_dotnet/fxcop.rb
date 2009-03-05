module Rake
	class FxCopTask < TaskLib
		def initialize(params={})
			@name = paramsname
			@suites_dir = params[:suites_dir] || File.join(OUT_DIR, 'bin')
			@product_name = params[:product_name] || PRODUCT_NAME
			@report_file = params[:report_file] || File.join(OUT_DIR, 'reports', @product_name + '.fxcop.xml')
			@dll_list = FileList.new
			@deps = params[:deps] || []
			
			yield self if block_given?
			define
		end
		
		def define
			@deps.each do |d|
				task :fxcop => d
			end

			file @name do |f|
				runner = FxCop.new(@dll_list) do |f|
					f.out_file = @name
				end
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
		@exe = params[:fxcop_exe] || File.join(TOOLS_DIR, 'fxcop', 'fxcopcmd.exe')
		@dlls = dlls
		
		yield self if block_given?
	end
	
	def console
		'/console' if @echo_to_console || @out_file.nil?
	end

	def files_to_analyse
		list = ''
		@dlls.each do |dll|
			list += "/file:#{dll} "
		end
		list = list.chop
	end

	def out_file
		"/out:#{@out_file}" if @out_file
	end

	def out_xsl
		"/outxsl:#{@out_xsl}" if @out_xsl
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
