class NDependTask < Rake::TaskLib
	include DependentTask

	attr_accessor :options, :out_dir, :dependencies

	def initialize(params={})
		@main_task_name = :ndepend
		super(params)
		@out_dir = params[:out_dir] || File.join(OUT_DIR, 'reports', 'ndepend')

		@options = params[:options] || {}
		@options[:out_dir] = @out_dir if @options[:out_dir].nil?
		@options[:project] = PRODUCT_NAME + '.ndepend.xml' if @options[:project].nil?

		yield self if block_given?
		define
	end

	def define
		directory @out_dir
		task :ndepend => [@out_dir]

		project = @options[:project]
		project_template = "#{project}.erb"
		if File.exist?(project_template)
			CLEAN.include(project)

			file project do
				erb_template = File.read(project_template)
				erb = ERB.new(erb_template)
				data = NDependProject.new(@options[:out_dir], Bin_out)
				result = erb.result(data.get_binding)
				File.open(project, 'w') { |f| f.puts result }
			end
		end

		task :ndepend => @options[:project]

		desc "Run ndepend u"
		task :ndepend do
			ndt = NDependConsoleCmd.new(:options => @options)
			ndt.run
		end

		task :clobber_ndepend do
			rm_rf @out_dir
		end
	end
end

class NDependProject
	attr_accessor :out_dir, :bin_dir

	def initialize(out_dir, bin_dir)
		@out_dir = out_dir
		@bin_dir = bin_dir
	end

	def get_binding
		binding
	end
end
