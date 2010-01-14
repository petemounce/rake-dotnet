class NCoverReportingCmd
	def initialize(report_dir, coverage_files, params)
		@report_dir = report_dir
		@coverage_files = coverage_files || []

		params ||= {}
		arch = params[:arch] || ENV['PROCESSOR_ARCHITECTURE']
		@exe = params[:ncover_reporting_exe] || File.join(TOOLS_DIR, 'ncover', arch, 'ncover.reporting.exe')

		@is_complete_version = `#{@exe}`.include?('NCover Reporting Complete')
		# required
		@reports = params[:reports] || ['Summary', 'UncoveredCodeSections', 'FullCoverageReport']
		@output_path = File.join(@report_dir)

		# optional
		@sort_order = params[:sort] || 'CoveragePercentageAscending'
		@project_name = params[:project_name] || PRODUCT_NAME
	end

	def coverage_files
		list = ''
		@coverage_files.each do |cf|
			list += "\"#{cf}\" "
		end
		return list
	end

	def build_id
		return "//bi #{Versioner.new.get.to_s}"
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
		return "//op \"#{@output_path}\""
	end

	def sort_order
		return "//so #{@sort_order}"
	end

	def project_name
		return "//p #{@project_name}" unless @project_name.nil?
	end

	def cmd
		return "\"#{@exe}\" #{coverage_files} #{build_id} #{output_reports} #{output_path} #{sort_order} #{project_name}"
	end

	def run
		puts cmd if VERBOSE
		sh cmd
	end
end
