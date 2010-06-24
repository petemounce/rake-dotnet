class XUnitTask < Rake::TaskLib
  include DependentTask

  attr_accessor :suites_dir, :reports_dir, :options

	def initialize(params={}) # :yield: self
    @main_task_name = :xunit
    params[:build_number] ||= ENV['BUILD_NUMBER']
		@suites_dir = params[:suites_dir] || File.join(OUT_DIR, 'bin')
		@reports_dir = params[:reports_dir] || File.join(OUT_DIR, 'reports', 'tests')
		@options = params[:options] || {:xml => true, :out_dir=>@reports_dir}

		yield self if block_given?
    super(params)
		define
	end

	# Create the tasks defined by this task lib.
	def define
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
				x = XUnitCmd.new(tests_dll, out_dir, nil, @options)
				x.run
			end
		end

		directory @reports_dir

    desc "Generate test reports inside of each directory specified, where each directory matches a test-suite name (give relative paths) (otherwise, all matching #{@suites_dir}/*Tests.*.dll) and write reports to #{@reports_dir}"
		task :xunit, [:reports] => [@reports_dir] do |t, args|
			reports_list = FileList.new("#{@suites_dir}/**/*Tests*.dll").pathmap("#{@reports_dir}/%n/")
			args.with_defaults(:reports => reports_list)
			args.reports.each do |r|
				Rake::FileTask[r].invoke
			end
		end

		task :clobber_xunit do
			rm_rf(@reports_dir)
		end

		task :tests => :xunit
	end
end
