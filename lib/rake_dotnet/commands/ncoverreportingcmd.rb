class NCoverReportingCmd < Cli
  def initialize(params={})
    @arch = params[:arch] || ENV['PROCESSOR_ARCHITECTURE']
    sps = params[:search_paths] || []
    sps << File.join(TOOLS_DIR, 'NCover', @arch)
    sps << File.join(ENV['PROGRAMFILES'], 'NCover')
    super(params.merge(:exe_name => 'ncover.reporting.exe', :search_paths => sps))

    @coverage_files = params[:coverage_files] || []
    raise(ArgumentError, 'Must supply :coverage_files array', caller) if @coverage_files.length == 0
    @out_dir = params[:out_dir] || File.join(OUT_DIR, 'reports', 'ncover')
    code, stdout, stderr = systemu exe unless params[:is_complete_version]
    @is_complete_version = params[:is_complete_version] || stdout.include?('NCover Reporting Complete')
    @version = params[:version] || Versioner.new.get.to_s
    @coverage_files = params[:coverage_files] || []
		@reports = params[:reports] || ['Summary', 'UncoveredCodeSections', 'FullCoverageReport']
		@sort_order = params[:sort] || 'CoveragePercentageAscending'
		@project_name = params[:project_name] || PRODUCT_NAME
		@save_to = params[:save_to]
	end

	def coverage_files
		list = ''
		@coverage_files.each do |cf|
			list += "\"#{cf}\" "
		end
		return list
	end

	def build_id
    return "//bi #{@version}"
	end

	def output_reports
		cmd = ''
		if @is_complete_version
			@reports.each do |r|
				cmd += "//or #{r} "
			end
		else
			classic_version_reports_allowed = ['Summary', 'SymbolModule', 'SymbolModuleNamespace', 'SymbolModuleNamespaceClass', 'SymbolModuleNamespaceClassMethod']
			@reports.each do |r|
				cmd += "//or #{r} " if classic_version_reports_allowed.include?(r)
			end
		end
		return cmd
	end

	def output_path
    set = Pathname.new(@coverage_files.first).basename.sub('.coverage.xml', '')
    op = File.expand_path(File.join(@out_dir, set)).gsub('/', '\\')
    return "//op \"#{op}\""
	end

	def sort_order
		return "//so #{@sort_order}"
	end

	def project_name
		return "//p #{@project_name}" unless @project_name.nil?
	end

	def save_to
		return "//s #{@save_to}" unless @save_to.nil?
	end

	def cmd
    return "#{super} #{coverage_files} #{build_id} #{output_reports} #{output_path} #{sort_order} #{project_name} #{save_to}"
	end

	def run
		puts cmd if verbose
		sh cmd
	end
end
