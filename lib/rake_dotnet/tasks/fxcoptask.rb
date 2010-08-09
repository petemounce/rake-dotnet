class FxCopTask < Rake::TaskLib
  include DependentTask
	attr_accessor :dll_list, :suites_dir, :product_name, :report_dir, :name

	def initialize(params={})
    @main_task_name = :fxcop
    params[:build_number] ||= ENV['BUILD_NUMBER']
		@product_name = params[:product_name] || PRODUCT_NAME
		@report_dir = params[:report_dir] || File.join(OUT_DIR, 'reports')
		@name = params[:name] || File.join(@report_dir, @product_name + '.fxcop')
		@suites_dir = params[:suites_dir] || File.join(OUT_DIR, 'bin')
		@dll_list = FileList.new
		@fxcop_options = params[:fxcop_options] || {}
		if @fxcop_options[:apply_out_xsl].nil? || @fxcop_options[:apply_out_xsl] == false
			@name += '.xml'
		else
			@name += '.html'
		end
		@fxcop_options[:out_file] = @name if @fxcop_options[:out_file].nil?

		yield self if block_given?
    super(params)
		define
	end

	def define
		directory @report_dir

    file @name => [@report_dir] do
			@fxcop_options[:dlls] = @dll_list
			runner = FxCopCmd.new(@fxcop_options)
			runner.run
		end

    task @main_task_name, :include_globs, :exclude_globs do |t, args|
			args.with_defaults(:include_globs => ["#{@suites_dir}/**/*#{@product_name}*.dll",
			                                      "#{@suites_dir}/**/*#{@product_name}*.exe"],
			                   :exclude_globs => ["#{@suites_dir}/*Tests*.dll",
			                                      "#{@suites_dir}/*.vshost.exe"])
			args.include_globs.each do |g|
				@dll_list.include g
			end
			args.exclude_globs.each do |g|
				@dll_list.exclude g
			end
			Rake::FileTask[@name].invoke
		end

		task :clobber_fxcop do
			rm_rf @report_dir
		end
	end
end
