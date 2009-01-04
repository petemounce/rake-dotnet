module Rake
	class RDNPackageTask < TaskLib
		def initialize(name=:package, params={})
			@name = name
			@in_dir = params[:in_dir] || []
			@out_dir = params[:out_dir] || ''
			@out_file = params[:out_file] || @name.to_s + '.zip'
			@path_to_snip = params[:path_to_snip] || ''
			@deps = params[:deps] || []
			yield self if block_given?
			define
		end
		
		def define
			of = "#{@out_dir}/#{@out_file}"
			of_regex = regexify(of)
			
			rule(/#{of_regex}/) do |r|
				target = @in_dir.sub(@path_to_snip + '/', '')
				chdir(@path_to_snip) do
					sh "zip -r #{@out_file} #{target}"
				end
			end
			
			directory @out_dir
			
			@deps.each do |d|
				file of => d
			end
			
			desc "Package up output into zip file"
			task :package => [@out_dir, of]
			
			task :clobber_package do
				rm_rf of
			end
			
			task :repackage => [:clobber_package, :package]
			
			self
		end
	end
end