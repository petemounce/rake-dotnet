class NDependTask < Rake::TaskLib
	include DependentTask

	attr_accessor :options, :out_dir, :dependencies, :globs

	def initialize(params={})
		@main_task_name = :ndepend
		params[:build_number] ||= ENV['BUILD_NUMBER']
		@out_dir = params[:out_dir] || File.join(OUT_DIR, 'reports', 'ndepend')
		@globs = params[:globs] || [File.join(Bin_out, "**", "#{PRODUCT_NAME}*.dll")]

		@options = params[:options] || {}
		@options[:out_dir] = @out_dir if @options[:out_dir].nil?
		@options[:project] = File.join(PRODUCT_ROOT, "#{PRODUCT_NAME}.ndepend.xml") if @options[:project].nil?

		yield self if block_given?
    super(params)
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
				data = NDependProject.new(@options[:out_dir], Bin_out, @globs)
				result = erb.result(data.get_binding)
				File.open(project, 'w') { |f| f.puts result }
			end
		end

		task :ndepend => @options[:project]

		desc "Run ndepend against the build output"
		task :ndepend do
			ndt = NDependConsoleCmd.new(@options)
			ndt.run
		end

		task :clobber_ndepend do
			rm_rf @out_dir
		end
	end
end

class NDependProject
	attr_accessor :out_dir, :bin_dir, :assembly_names

	def initialize(out_dir, bin_dir, globs)
		@out_dir = File.expand_path(out_dir).gsub('/', '\\')
		@bin_dir = File.expand_path(bin_dir).gsub('/', '\\')
		@assembly_names = []
		FileList.new(globs).each do |f|
			matches = f.match(/.*\/([\w\.-_]+)\.dll/)
			unless matches[1].nil?
				name = matches[1]
				@assembly_names << name unless @assembly_names.include? name
			end
		end
	end

	def get_binding
		binding
	end
end
