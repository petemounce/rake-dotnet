class NCoverExplorer
	attr_accessor :exe, :coverage_files, :html, :report, :min, :fail_min, :sort, :filter, :save
	def initialize(coverage_files)
		@exe = File.join(TOOLS_DIR, 'ncover', 'x86', 'ncoverexplorer.console.exe')
		@coverage_files = coverage_files
	end
	
	def coverage_files
		@coverage_files.join(' ')
	end
	def html
		"/html:#{@html}" unless @html.nil?
	end
	def report
		"/report:#{@report}" if @report
	end
	def min
		"/minCoverage:#{@min}" if @min
	end
	def fail_min
		"/f" if @fail_min
	end
	def sort
		"/sort:#{@sort}" if @sort
	end
	def filter
		"/filter:#{@filter}" if @filter
	end
	def save
		"/save:#{@save}" if @save
	end
		
	def cmd
		"\"#{@exe}\" #{coverage_files} #{html} #{report} #{min} #{fail_min} #{sort} #{filter} #{save}"
	end
	
	def run
		sh cmd
	end
end
