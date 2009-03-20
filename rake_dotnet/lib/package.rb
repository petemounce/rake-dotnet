module Rake
	class RDNPackageTask < TaskLib
		def initialize(name, version, params={})
			@name = name
			@version = version
			@in_dir = params[:in_dir] || []
			@out_dir = params[:out_dir] || OUT_DIR
			@out_file = params[:out_file] || @name.to_s
			@path_to_snip = params[:path_to_snip] || OUT_DIR
			@deps = params[:deps] || []
			@configuration = params[:configuration] || CONFIGURATION
			
			yield self if block_given?
			define
		end
		
		def define
			@package_file = "#{@out_dir}/#{out_file}.zip"
			@package_file_regex = regexify(@package_file)
			
			@deps.each do |d|
				file @package_file => d
				task :package => d
			end
			
			rule(/#{@package_file_regex}/) do |r|
				puts 'pfr: ' + @package_file
				target = @in_dir.sub(/#{@path_to_snip}\/?/, '')
				renamed = "#{target}-#{@configuration}-v#{@version}"
				cp_r("#{@out_dir}/#{target}", "#{@out_dir}/#{renamed}")
				chdir(@path_to_snip) do
					sh "zip -r #{out_file}.zip #{renamed}"
				end
			end
			
			directory @out_dir
			
			desc "Generate zip'd packages for all package-tasks"
			task :package => [@out_dir, @package_file]
			
			desc "Delete all packages"
			task :clobber_package do
				rm_rf @package_file
			end
			
			desc "Delete all packages and recreate them"
			task :repackage => [:clobber_package, :package]
			
			self
		end
		
		def out_file
			of = @out_file.sub(/#{@path_to_snip}\/?/, '') + "-#{@configuration}-v#{@version}"
		end
	end
end