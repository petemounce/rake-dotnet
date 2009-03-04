class FxCop
	attr_accessor :dlls, :out_file, :out_xsl, :apply_out_xsl, :dependencies_path, :summary, :verbose, :echo_to_console, :xsl_echo_to_console, :ignore_autogen, :culture
	def initialize(dlls)
		@exe = File.join(TOOLS_DIR, 'fxcop', 'fxcopcmd.exe')
		@dlls = dlls
	end
	
	def console
		'/console' if @echo_to_console
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
