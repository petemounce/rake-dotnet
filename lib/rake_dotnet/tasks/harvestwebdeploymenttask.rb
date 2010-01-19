class HarvestWebDeploymentTask < Rake::TaskLib
	include DependentTask
	
	attr_accessor :out_dir, :src_dir, :configuration, :include

	def initialize(params={})
		@out_dir = params[:out_dir] || OUT_DIR
		@src_dir = params[:src_dir] || SRC_DIR
		@configuration = params[:configuration] || CONFIGURATION
		@include = params[:to_harvest] || ['*']
		yield self if block_given?
		define
	end

	def define
		directory @out_dir

		out_dir_regex = regexify(@out_dir)
		rule(/#{out_dir_regex}\/.*\.WdpSite\//) do |r|
			harvest_to(r.name)
		end

		def harvest_to(path)
			name = path.sub(@out_dir + '/', '')
			source = File.join(@src_dir, name, @configuration)
			dest = File.join(@out_dir, name)
			mkdir_p dest
			result = FileList.new
			@include.each do |glob|
				result.include("#{source}/#{glob}")
			end
			result.each do |entry|
				pn = Pathname.new(entry)
				cp(pn, path) unless pn.directory?
				cp_r(pn, path) if pn.directory?
			end
		end

		'harvest all web-deployment project outputs'
		task :harvest_wdps => @out_dir

		task :harvest_wdps do
			FileList.new("#{@src_dir}/*.WdpSite/").each do |wdp|
				name = Pathname.new(wdp).basename
				path = File.join(@out_dir, name)
				Rake::Task["#{path}/"].invoke
			end
		end
		
		desc 'run all harvest-related tasks'
		task :harvest => :harvest_wdps
	end
end
