class FxCopCmd < Cli
	attr_accessor :dlls, :out_file, :out_xsl, :apply_out_xsl, :dependencies_path, :summary, :verbose, :echo_to_console, :xsl_echo_to_console, :ignore_autogen, :culture

  def initialize(params={})
    sps = params[:search_paths] || []
    sps << File.join(TOOLS_DIR, 'FxCop')
    sps << File.join(ENV['PROGRAMFILES'], 'Microsoft FxCop 1.36')
    sps << File.join(ENV['PROGRAMFILES'], 'Microsoft FxCop')
    super(params.merge(:exe_name => 'fxcopcmd.exe', :search_paths => sps))

    @dlls = params[:dlls]
	raise(ArgumentError, 'Must supply at least one DLL', caller) if @dlls.nil?

		@apply_out_xsl = params[:apply_out_xsl]
		@culture = params[:culture]
		@dependencies_path = params[:dependencies_path]
		@echo_to_console = params[:echo_to_console]
		@ignore_autogen = params[:ignore_autogen] || true
		@out_file = params[:out_file]
    exe_dir = Pathname.new(exe).dirname
    @out_xsl = File.join(exe_dir, 'Xml', params[:out_xsl]) unless params[:out_xsl].nil?
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
    "#{super} #{files_to_analyse} #{console} #{out_file} #{out_xsl} #{apply_out_xsl}"
	end

	def run
		puts cmd if verbose
		sh cmd
		puts "##teamcity[importData type='FxCop' path='#{File.expand_path(@out_file)}']" if ENV['BUILD_NUMBER']
	end
end
