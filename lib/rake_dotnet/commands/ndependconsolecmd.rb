class NDependConsoleCmd < Cli
	attr_accessor :project, :out_dir
	
	def initialize(params={})
		sps = params[:search_paths] || []
		sps << File.join(TOOLS_DIR, 'ndepend')
		super(params.merge(:exe_name=>'ndepend.console.exe', :search_paths=>sps))

		@project = params[:project] || PRODUCT_NAME + '.ndepend.xml'
		@out_dir = params[:out_dir] || File.join(OUT_DIR, 'reports', 'ndepend')
	end

	def out_dir
		od = File.expand_path(@out_dir).gsub('/','\\')
		return "/OutDir \"#{od}\""
	end

	def project
		p = File.expand_path(@project).gsub('/','\\')
		return "\"#{p}\""
	end

	def cmd
		return "#{super} #{project} #{out_dir}"
	end

	def run
		puts cmd if VERBOSE
		sh cmd
	end
end
