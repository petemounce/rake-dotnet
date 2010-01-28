class FxCopTask < Rake::TaskLib
	attr_accessor :dll_list, :suites_dir, :product_name, :report_dir, :name

	def initialize(params={})
		@product_name = params[:product_name] || PRODUCT_NAME
		@report_dir = params[:report_dir] || File.join(OUT_DIR, 'reports')
		@name = params[:name] || File.join(@report_dir, @product_name + '.fxcop')
		@suites_dir = params[:suites_dir] || File.join(OUT_DIR, 'bin')
		@dll_list = FileList.new
		@deps = params[:deps] || []
		@fxcop_options = params[:fxcop_options] || {}
		if @fxcop_options[:apply_out_xsl].nil? || @fxcop_options[:apply_out_xsl] == false
			@name += '.xml'
		else
			@name += '.html'
		end
		@fxcop_options[:out_file] = @name if @fxcop_options[:out_file].nil?

		yield self if block_given?
		define
	end

	def define
		@deps.each do |d|
			task :fxcop => d
		end

		directory @report_dir

		file @name => [@report_dir] do |f|
			runner = FxCopCmd.new(@dll_list, @fxcop_options)
			runner.run
		end

		task :fxcop, :include_globs, :exclude_globs do |t, args|
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
