class FxCopCmd
	attr_accessor :dlls, :out_file, :out_xsl, :apply_out_xsl, :dependencies_path, :summary, :verbose, :echo_to_console, :xsl_echo_to_console, :ignore_autogen, :culture

	def initialize(dlls, params={})
		@dlls = dlls
#		raise(ArgumentError, 'Must supply at least one DLL', caller) if @dlls.nil?

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
			list += "/file:\"#{dll.gsub('/', '\\')}\" "
		end
		list = list.chop
	end

	def out_file
		return '' if @out_file.nil?
		return "/out:\"#{@out_file.gsub('/', '\\')}\""
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
		puts cmd if verbose
		sh cmd
		puts "##teamcity[importData type='FxCop' path='#{File.expand_path(@out_file)}']" if ENV['BUILD_NUMBER']
	end
end
