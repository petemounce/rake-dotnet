module Rake
	class HarvestWebApplicationTask < TaskLib
		def initialize(params={})
			@src_path = params[:src_path] || 'src'
			@target_path = params[:target_path] || 'build'
			@deps = params[:deps] || []
			@tools_dir = params[:tools_dir] || File.join('..','..','_library')
			@default_glob = params[:default_glob] || '*Site*'
			yield self if block_given?
			define
		end
		
		def define
			out_dir_regex = regexify(@target_path)
			
			rule(/#{out_dir_regex}\/[\w\.-_ ]*Site[\w\.-_ ]*\//) do |r|
				web_app_name = r.name.match(/#{out_dir_regex}\/([\w\.-_ ]*Site[\w\.-_ ]*)\//)[1]
				src = File.join(@src_path, web_app_name)
				svn = SvnExport.new(src, r.name, {:tools_dir => @tools_dir})
				svn.export
				cp_r(File.join(src, 'bin'), r.name)
			end
			
			desc "Harvest specified web-applications (or all matching #{@src_path}/#{@default_glob}) to #{@target_path}"
			task :harvest_webapps,[:web_app_list] => @target_path do |t, args|
				list = FileList.new("#{@src_path}/#{@default_glob}")
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
	end
end

class Harvester
	attr_accessor :files, :target
	
	def initialize(target)
		@files = Hash.new
		@target = target
	end
	
	def add(glob)
		toAdd = Dir.glob(glob)
		toAdd.each do |a|
			pn = Pathname.new(a)
			@files[pn.basename.to_s] = pn
		end
	end
	
	def harvest
		mkdir_p(@target) unless File.exist?(@target)
		@files.sort.each do |k, v|
			cp(v, @target)
		end
	end
	
	def list
		@files.sort.each do |k, v| 
			puts k + ' -> ' + v
		end
	end
end