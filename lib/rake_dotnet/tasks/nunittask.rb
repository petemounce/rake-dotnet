class NUnitTask < Rake::TaskLib
	include DependentTask
	
	attr_accessor :suites_dir, :out_dir, :runner_options

	def initialize(params={})
		@main_task_name = :nunit
		super(params)
		@suites_dir = params[:suites_dir] || File.join(OUT_DIR, 'bin')
		@out_dir = params[:out_dir] || File.join(OUT_DIR, 'reports', 'nunit')
		@runner_options = params[:runner_options] || {:xml=>true, :out_dir=>@out_dir}
		@runner_options[:include].merge(params[:include]) unless params[:include].nil?
		@runner_options[:exclude].merge(params[:exclude]) unless params[:exclude].nil?

		yield self if block_given?
		define
	end

	def define
		directory @out_dir

		task @main_task_name => [@out_dir]

		task :clobber_nunit do
			rm_rf @out_dir
		end

		rule(/#{@out_dir}\/.*Tests.*\//) do |r|
			suite = r.name.match(/.*\/(.*Tests)\//)[1]
			run(suite)
		end

		def run(suite)
			tests_dll = File.join(@suites_dir, suite + '.dll')
			out_dir = File.join(@out_dir, suite)
			unless File.exist?(out_dir) && uptodate?(tests_dll, out_dir)
				mkdir_p(out_dir) unless File.exist?(out_dir)
				n = NUnitCmd.new(:input_files=>tests_dll, :options=>@runner_options)
				n.run
			end
		end

		desc "Generate xml test reports from nunit and write reports to #{@out_dir}"
		task @main_task_name, :exclude, :include do |t, args|
			suites = FileList.new("#{@suites_dir}/**/*Tests*.dll").pathmap("#{@out_dir}/%n/")
			args.with_defaults(:exclude => '', :include => '')
			@exclude = args[:exclude].split(';')
			@include = args[:include].split(';')
			suites.each do |r|
				Rake::FileTask[r].invoke
			end
		end

		task :tests => @main_task_name
	end
end
