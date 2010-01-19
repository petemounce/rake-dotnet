class HarvestWebApplicationTask < Rake::TaskLib
	include DependentTask

	attr_accessor :out_dir

	def initialize(params={})
		@main_task_name = :harvest_webapps
		super(params)
		@src_path = params[:src_path] || File.join(PRODUCT_ROOT, 'src')
		@out_dir = params[:target_path] || OUT_DIR
		@glob = params[:glob] || "**/*.Site"

		yield self if block_given?
		define
	end

	def define
		out_dir_regex = regexify(@out_dir)

		odr = /#{out_dir_regex}\/([\w\.-_ ]*\.Site)\//
		rule(odr) do |r|
			harvest(r.name, odr)
		end

		directory @out_dir
		task :harvest_webapps => @out_dir

		desc "Harvest specified web-applications (or all matching #{@src_path}/#{@glob}) to #{@out_dir}"
		task :harvest_webapps, :web_app_list do |t, args|
			list = FileList.new("#{@src_path}/#{@glob}")
			args.with_defaults(:web_app_list => list)
			args.web_app_list.each do |w|
				pn = Pathname.new(w)
				out = File.join(@out_dir, pn.basename) + '/'
				Rake::FileTask[out].invoke
			end
		end

		desc 'run all harvest-related tasks'
		task :harvest => :harvest_webapps
	end

	def harvest(path, regex)
		web_app_name = path.match(regex)[1]
		src = File.join(@src_path, web_app_name)
		if (File.exist?("#{src}/.svn"))
			svn = SvnExport.new({:src=>src, :dest=>path})
			svn.run
			cp_r(File.join(src, 'bin'), path)
		else
			cp_r src, path
		end
		FileList.new("#{path}**/obj").each do |e|
			rm_rf e if File.exist? e
		end
	end
end
