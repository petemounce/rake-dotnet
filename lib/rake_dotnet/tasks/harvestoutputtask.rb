class HarvestOutputTask < Rake::TaskLib
	include DependentTask
	
	attr_accessor :src_dir, :out_dir, :configuration, :glob

	def initialize(params={})
		@main_task_name = :harvest_output
		super(params)
		@src_dir = params[:src_dir] || File.join(PRODUCT_ROOT, 'src')
		@out_dir = params[:out_dir] || Bin_out
		@configuration = params[:configuration] || CONFIGURATION
		@glob = params[:glob] || ["#{@src_dir}/*"]

		yield self if block_given?
		define
	end

	def define
		directory @out_dir
		task @main_task_name => @out_dir

		desc "Harvest specified libraries (or all matching #{@glob}) to #{@out_dir}"
		task @main_task_name, [:to_harvest_list] do |t, args|
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
					output.include("#{entry}/bin/#{@configuration}/*") # Libraries
					output.include("#{entry}/bin/*") # Web Application Project
					output.include("#{entry}/#{@configuration}/bin/*") #Web Deployment Project
					output.each do |o|
						o_pn = Pathname.new(o)
						to_pn = Pathname.new("#{@out_dir}")
						if (o_pn.directory?)
							cp_r(o, to_pn) unless o_pn.to_s.match(/#{@configuration}$/)
						else
							cp(o, to_pn)
						end
					end
				end
			end
		end

		desc 'run all harvest-related tasks'
		task :harvest => :harvest_output
	end
end
