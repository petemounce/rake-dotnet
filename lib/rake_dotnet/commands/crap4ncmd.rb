class Crap4nCmd < Cli
	def initialize(params={})
		sps = params[:search_paths] || []
		sps << File.join(TOOLS_DIR, 'crap4n')
		super(params.merge(:exe_name=>'crap4n-console.exe',:search_paths=>sps))

		@name = params[:name]
		raise(ArgumentError, 'crap4n report name is required', caller) if @name.nil?
		@out_dir = params[:out_dir] || File.join(OUT_DIR, 'reports')
	end

	def cc
		file = File.expand_path(File.join(@out_dir, 'ncover', @name, "#{@name}.coverage.xml")).gsub('/','\\')
		return "/cc=\"#{file}\""
	end

	def cm
		file = File.expand_path(File.join(@out_dir, 'ncover', @name, "#{@name}.coverage.xml")).gsub('/','\\')
		return "/cm=\"#{file}\""
	end

	def xml
		file = File.expand_path(File.join(@out_dir, 'crap4n', "#{@name}.crap4n.xml")).gsub('/','\\')
		return "/xml=\"#{file}\""
	end

	def cmd
		return "#{super} #{cc} #{cm} #{xml}"
	end

	def run
		puts cmd if verbose
		sh cmd
	end
end
