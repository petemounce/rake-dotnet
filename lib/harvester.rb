class HarvestOutputTask < Rake::TaskLib
	def initialize(params={})
		@src_path = params[:src_path] || File.join(PRODUCT_ROOT, 'src')
		@target_path = params[:target_path] || Bin_out
		@deps = params[:deps] || []
		@configuration = params[:configuration] || CONFIGURATION
		@glob = params[:glob] || ["#{@src_path}/*"]

		yield self if block_given?
		define
	end

	def define
		directory @target_path

		desc "Harvest specified libraries (or all matching #{@glob}) to #{@target_path}"
		task :harvest_output, [:to_harvest_list] => @target_path do |t, args|
			list = FileList.new
			@glob.each do |g|
				list.include(g)
			end
			args.with_defaults(:to_harvest_list => list)
			args.to_harvest_list.each do |entry|
				pn = Pathname.new(entry)
				if pn.directory?
					output = FileList.new
					#TODO: distinguish between web and class and console output
					output.include("#{entry}/bin/#{@configuration}/*")
					output.include("#{entry}/bin/*")
					output.each do |o|
						o_pn = Pathname.new(o)
						to_pn = Pathname.new("#{@target_path}")
						if (o_pn.directory?)
							cp_r(o, to_pn) unless o_pn.to_s.match(/#{@configuration}$/)
						else
							cp(o, to_pn)
						end
					end
				end
			end
		end

		@deps.each do |d|
			task :harvest => d
		end

		self
	end
end

class HarvestWebApplicationTask < Rake::TaskLib
	def initialize(params={})
		@src_path = params[:src_path] || File.join(PRODUCT_ROOT, 'src')
		@target_path = params[:target_path] || OUT_DIR
		@deps = params[:deps] || []
		@glob = params[:glob] || "**/*.Site"

		yield self if block_given?
		define
	end

	def define
		out_dir_regex = RakeDotNet::regexify(@target_path)

		odr = /#{out_dir_regex}\/([\w\.-_ ]*Site)\//
		rule(odr) do |r|
			harvest(r.name, odr)
		end
		
		desc "Harvest specified web-applications (or all matching #{@src_path}/#{@glob}) to #{@target_path}"
		task :harvest_webapps, [:web_app_list] => @target_path do |t, args|
			list = FileList.new("#{@src_path}/#{@glob}")
			args.with_defaults(:web_app_list => list)
			args.web_app_list.each do |w|
				pn = Pathname.new(w)
				out = File.join(@target_path, pn.basename) + '/'
				Rake::FileTask[out].invoke
			end
		end

		@deps.each do |d|
			task :harvest_webapps => d
		end

		self
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

class Harvester
	attr_accessor :files, :target

	def initialize
		@files = Hash.new
	end

	def add(glob)
		toAdd = Dir.glob(glob)
		toAdd.each do |a|
			pn = Pathname.new(a)
			@files[pn.basename.to_s] = pn
		end
	end

	def harvest(target)
		mkdir_p(target) unless File.exist?(target)
		@files.sort.each do |k, v|
			cp(v, target)
		end
	end

	def list
		@files.sort.each do |k, v|
			puts k + ' -> ' + v
		end
	end
end
