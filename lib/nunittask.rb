class NUnitTask < Rake::TaskLib
  attr_accessor :suites_dir, :reports_dir, :runner_options, :dependencies

  def initialize(params={})
    @suites_dir = params[:suites_dir] || File.join(OUT_DIR, 'bin')
    @reports_dir = params[:reports_dir] || File.join(OUT_DIR, 'reports', 'nunit')
    @runner_options = params[:runner_options] || {}
    @dependencies = params[:dependencies] || []

    yield self if block_given?
    define
  end

  def define
    @dependencies.to_a.each do |d|
      task :nunit => d
    end

    directory @reports_dir

    task :nunit => [@reports_dir]

    task :clobber_nunit do
      rm_rf @reports_dir
    end

    rule(/#{@reports_dir}\/.*Tests.*\//) do |r|
      suite = r.name.match(/.*\/(.*Tests)\//)[1]
      run(suite)
    end

    def run(suite)
      tests_dll = File.join(@suites_dir, suite + '.dll')
      out_dir = File.join(@reports_dir, suite)
      unless File.exist?(out_dir) && uptodate?(tests_dll, out_dir)
        mkdir_p(out_dir) unless File.exist?(out_dir)
        n = NUnitCmd.new({:input_files=>tests_dll, :options=>@runner_options})
        n.run
      end
    end

    desc "Generate test reports (which ones, depends on the content of XUNIT_OPTS) inside of each directory specified, where each directory matches a test-suite name (give relative paths) (otherwise, all matching #{@suites_dir}/*Tests.*.dll) and write reports to #{@reports_dir}"
    task :nunit, [:reports] => [@reports_dir] do |t, args|
      reports_list = FileList.new("#{@suites_dir}/**/*Tests*.dll").pathmap("#{@reports_dir}/%n/")
      args.with_defaults(:reports => reports_list)
      args.reports.each do |r|
        Rake::FileTask[r].invoke
      end
    end
  end
end