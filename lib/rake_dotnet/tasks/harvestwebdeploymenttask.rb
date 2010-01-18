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
		rule(/#{out_dir_regex}\/.*WdpSite\//) do |r|
			puts 'rule: ' + r.name
			harvest_to(r.name)
		end

		def harvest_to(path)
			pn = Pathname.new(path)
			name = pn.basename
			source = File.join(@src_dir, name, @configuration)
			puts 'path: ' + path
			puts '****** source: ' + source
			mkdir_p File.join(pn.dirname, name)
			result = FileList.new
			@include.each do |glob|
				result.include("#{source}/#{glob}")
			end
			puts result.length
			result.each do |entry|
				puts '******* entry: ' + entry
				pn = Pathname.new(entry)
				cp(pn, path) unless pn.directory?
				cp_r(pn, path) if pn.directory?
			end
		end

		'harvest all web-deployment project outputs'
		task :harvest_wdps => @out_dir

		task :harvest_wdps do
			FileList.new("#{@src_dir}/*WdpSite").each do |wdp|
				name = Pathname.new(wdp).basename
				Rake::Task["#{@out_dir}/#{name}/"].invoke
			end
		end
		
		desc 'run all harvest-related tasks'
		task :harvest => :harvest_wdps
	end
end
