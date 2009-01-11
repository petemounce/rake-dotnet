module Rake
	class RDNPackageTask < TaskLib
		def initialize(name, params={})
			@name = name
			@in_dir = params[:in_dir] || []
			@out_dir = params[:out_dir] || ''
			@out_file = params[:out_file] || @name.to_s + '.zip'
			@path_to_snip = params[:path_to_snip] || '.'
			@deps = params[:deps] || []
			yield self if block_given?
			define
		end
		
		def define
			package_file = "#{@out_dir}/#{out_file}"
			package_file_regex = regexify(package_file)
			
			rule(/#{package_file_regex}/) do |r|
				target = @in_dir.sub(/#{@path_to_snip}\/?/, '')
				chdir(@path_to_snip) do
					sh "zip -r #{out_file} #{target}"
				end
			end
			
			directory @out_dir
			
			@deps.each do |d|
				file package_file => d
				task :package => d
			end
			
			desc "Generate zip'd packages for all package-tasks"
			task :package => [@out_dir, package_file]
			
			task :clobber_package do
				rm_rf package_file
			end
			
			task :repackage => [:clobber_package, :package]
			
			self
		end
		
		def out_file
			@out_file.sub(/#{@path_to_snip}\/?/, '')
		end
	end
end