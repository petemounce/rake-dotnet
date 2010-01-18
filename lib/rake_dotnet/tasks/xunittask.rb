class XUnitTask < Rake::TaskLib
	attr_accessor :suites_dir, :reports_dir, :options

	def initialize(params={}) # :yield: self
		@suites_dir = params[:suites_dir] || File.join(OUT_DIR, 'bin')
		@reports_dir = params[:reports_dir] || File.join(OUT_DIR, 'reports', 'tests')
		@options = params[:options] || {}
		@deps = params[:deps] || []

		yield self if block_given?
		define
	end

	# Create the tasks defined by this task lib.
	def define
		@deps.each do |d|
			task :xunit => d
		end

		rule(/#{@reports_dir}\/.*Tests.*\//) do |r|
			suite = r.name.match(/.*\/(.*Tests)\//)[1]
			run(suite)
		end

		rule(/xt-.*Tests.*/) do |r|
			suite = r.name.match(/xunit-(.*Tests)/)[1]
			run(suite)
		end

		def run(suite)
			tests_dll = File.join(@suites_dir, suite + '.dll')
			out_dir = File.join(@reports_dir, suite)
			unless File.exist?(out_dir) && uptodate?(tests_dll, out_dir)
				mkdir_p(out_dir) unless File.exist?(out_dir)
				x = XUnitCmd.new(tests_dll, out_dir, nil, options=@options)
				x.run
			end
		end

		directory @reports_dir

		desc "Generate test reports (which ones, depends on the content of XUNIT_OPTS) inside of each directory specified, where each directory matches a test-suite name (give relative paths) (otherwise, all matching #{@suites_dir}/*Tests.*.dll) and write reports to #{@reports_dir}"
		task :xunit, [:reports] => [@reports_dir] do |t, args|
			reports_list = FileList.new("#{@suites_dir}/**/*Tests*.dll").pathmap("#{@reports_dir}/%n/")
			args.with_defaults(:reports => reports_list)
			args.reports.each do |r|
				Rake::FileTask[r].invoke
			end
		end

		task :xunit_clobber do
			rm_rf(@reports_dir)
		end

		self
	end
end
