class NUnitCmd < Cli
	def initialize(params={})
		sps = params[:search_paths] || []
		sps << File.join(TOOLS_DIR, 'nunit', 'bin', 'net-2.0')
		sps << File.join(ENV['PROGRAMFILES'], 'nunit 2.5.3', 'bin', 'net-2.0')
		sps << File.join(ENV['PROGRAMFILES'], 'nunit 2.5.2', 'bin', 'net-2.0')
		sps << File.join(ENV['PROGRAMFILES'], 'nunit 2.5.1', 'bin', 'net-2.0')
		sps << File.join(ENV['PROGRAMFILES'], 'nunit 2.5.0', 'bin', 'net-2.0')
		sps << File.join(ENV['PROGRAMFILES'], 'nunit', 'bin', 'net-2.0')
		super(params.merge({:exe_name=>'nunit-console.exe', :search_paths=>sps}))

		if (params[:input_files].nil?)
			raise(ArgumentError, 'Must supply a DLL to run tests from', caller)
		else
			in_files = params[:input_files]
			@name = Pathname.new(in_files).basename.sub('.dll', '')
			@input_files = File.expand_path(in_files)
		end

		od = params[:out_dir] || File.join(OUT_DIR, 'reports', 'nunit', @name)
		@out_dir = File.expand_path(od)
		@options = params[:options] || {}
	end

	def no_xml
		return @options[:xml].nil? || @options[:xml] == false
	end

	def xml
		return '' if no_xml
		return "/xml=\"#{@out_dir.gsub('/', '\\')}\\#{@name}.nunit.xml\""
	end

	def dll
		return "\"#{@input_files.gsub('/', '\\')}\""
	end

	def include
		inc = @options[:include]
		return '' if inc.nil? || inc == '' || inc == []
		return "/include=#{inc.join(',')}" if inc.is_a?(Array)
		return "/include=#{inc}" if inc.is_a?(String)
	end

	def exclude
		exc = @options[:exclude]
		return '' if exc.nil? || exc == '' || exc == []
		return "/exclude=#{exc.join(',')}" if exc.is_a?(Array)
		return "/exclude=#{exc}" if exc.is_a?(String)
	end

	def cmd
		return "#{super} #{dll} #{xml} #{include} #{exclude}"
	end

	def run
		puts cmd if VERBOSE
		sh cmd
		if (ENV['BUILD_NUMBER'])
			puts "##teamcity[importData type='nunit' path='#{xml}']" unless no_xml
		end
	end
end
